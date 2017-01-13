class StacksController < ApplicationController
  include InstancesHelper
  skip_before_filter :require_admin


  def index
    if is_admin?
      @stacks = Stack.all
    else
      @stacks = @current_user.company.stacks
    end

    @title = "AWS Stacks"
    @cloudformation = Account.cf_client
    @ec2 = Account.ec2_client
  end


  def new
    @title = "Create New Stack"
    @templates = Template.all
    @companies = Company.all
    @stack = Stack.new
  end


  def create
    @stack = Stack.new(stack_params)
    stack_name = @stack.stack_name
    template_url = @stack.template.template_url
    company_name = @stack.company.company_name
    cloudformation = Account.cf_client
    if @stack.save
      new_stack = cloudformation.create_stack(stack_name: stack_name, 
                                              template_url: template_url,
                                              tags: [
                                                {
                                                  key: "Company",
                                                  value: company_name
                                                }
                                              ]
                                              )
      @stack.stack_id = new_stack[:stack_id]
      redirect_to stacks_path
    else
      flash[:danger] = @stack.errors.full_messages 
      render :new
    end
   
  end

  def show
    @stack = Stack.find(params[:id])
    @title = "Instances for #{@stack.stack_name}"
    @ec2 = Account.ec2_client
  end


  def edit

  end


  def update

  end


  def delete

  end


  def destroy
    #flash[:progress] = "Deleting Instances. This will take a few moments"
    @stack = Stack.find(params[:id])
    stack_name = @stack.stack_name
    cloudformation = Account.cf_client
    volumes = get_volumes(stack_name, cloudformation)
    #detach volumes
    ec2 = Account.ec2_client
    volume_state = 'in-use'
    attachment_state = 'attached'
    volumes.each do |volume|
      ec2.detach_volume(volume_id: volume, force: true)
    end
    volumes.each do |volume|
      until volume_state == 'available' && attachment_state == 'detached'
        resp = ec2.describe_volumes(volume_ids: [volume])
        volume_state =resp[0][0].state
        if resp[0][0].attachments.empty?
          attachment_state = 'detached'
        end
      end
      volume_state = 'in-use'
      attachment_state = 'attached'
    end
    cloudformation.delete_stack(stack_name: stack_name)
    #delete volumes
    volumes.each do |volume|
      ec2.delete_volume(volume_id: volume)
    end
    @stack.destroy
    redirect_to stacks_path
  end



  def stack_params
    params.require(:stack).permit(:stack_name,:template_id,:company_id)
  end


  def get_volumes(stack_name, cloudformation)
    resp = cloudformation.list_stack_resources(stack_name: stack_name)
    @resources = resp[0]

    #Find storage volumes for SX.e and Ming.le
    sxe = @resources.select{|resource|resource[:logical_resource_id] == 'sxeInstance'}
    sxe_id = sxe[0].physical_resource_id
    mng = @resources.select{|resource|resource[:logical_resource_id] == 'mingleInstance'}
    mng_id = mng[0].physical_resource_id
    ec2 = Account.ec2_client
    resp2 = ec2.describe_volumes({
      filters: [
        {
          name: 'attachment.instance-id',
          values: [sxe_id, mng_id]
        }
      ]
    })
    volumes = resp2.volumes
    standard_volumes = volumes.select{|volume| volume[:volume_type] == 'standard'}
    volume_list = []
    standard_volumes.each do |volume|
      volume_list << volume.volume_id
    end
    return volume_list
  end

  def get_instance_resources(stack_name)
    cloudformation = Account.cf_client
    resp = cloudformation.list_stack_resources({stack_name: stack_name})
    resources = resp[0]
    instance_resources = resources.select{|resource| resource.resource_type == 'AWS::EC2::Instance'}
    return instance_resources
  end
  
  def get_instance_ids(instance_resources)
    instance_ids = []
    instance_resources.each do |instance|
      instance_ids << instance.physical_resource_id
    end
    return instance_ids
  end


  def stop_instances
    ec2 = Account.ec2_client
    stack = Stack.find(params[:id])
    instance_resources = get_instance_resources(stack.stack_name)
    instance_ids = get_instance_ids(instance_resources)
    ec2.stop_instances(instance_ids: instance_ids, force: true)
    sleep(5.seconds)
    redirect_to stacks_path
  end

  def start_instances
    #flash[:progress] = "Starting Instances. This will take several minutes."
    ec2 = Account.ec2_client
    stack = Stack.find(params[:id])
    instance_resources = get_instance_resources(stack.stack_name)
    #Start Domain Controller
    domain_controller = instance_resources.select{
      |resource| resource.logical_resource_id == "dcInstance"
    }[0]
    domain_controller_id = domain_controller.physical_resource_id
    ec2.start_instances(instance_ids: [domain_controller_id])
    instance_resources.delete(domain_controller)
    #Wait
    sleep(2.minutes)
    #Start SX.e Server
    sxe_server = instance_resources.select{
      |resource| resource.logical_resource_id == "sxeInstance"
    }[0]
    sxe_server_id = sxe_server.physical_resource_id
    ec2.start_instances(instance_ids: [sxe_server_id])
    instance_resources.delete(sxe_server)
    sleep(3.minutes)
    #Start Everything Else
    instance_ids = get_instance_ids(instance_resources)
    ec2.start_instances(instance_ids: instance_ids)
    redirect_to stacks_path
  end
end
