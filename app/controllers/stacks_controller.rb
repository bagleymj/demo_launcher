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
    manual_template = Template.new(:template_name => "Manual - No Template")
    @templates = Template.all
    @templates.unshift(manual_template)
    @companies = Company.all
    @stack = Stack.new
  end


  def create
    @stack = Stack.new(stack_params)
    if @stack.save
      unless @stack.template_id.nil?
        cloudformation = Account.cf_client
        new_stack = cloudformation.create_stack(stack_name: @stack.stack_name, 
                                                template_url: @stack.template.template_url,
                                                tags: [
                                                  {
                                                    key: "Company",
                                                    value: @stack.company.company_name
                                                  }
                                                ]
                                                )
        @stack.stack_id = new_stack[:stack_id]
      end
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
    @stack = Stack.find(params[:id])
    @title = "Edit boot order for #{@stack.stack_name}"
    @ec2 = Account.ec2_client
  end

  def modify_boot_order
    stack = Stack.find(params[:stack_id])
    instance = Instance.find(params[:instance_id])
    direction = params[:direction]
    current_boot_order = instance.boot_order
    new_boot_order = nil
    if direction == "up"
      new_boot_order = current_boot_order - 1
    end
    if direction == "down"
      new_boot_order = current_boot_order + 1
    end
    bumped_instance = stack.instances.select{|found_instance|found_instance.boot_order == new_boot_order}[0]
    bumped_instance.update_attributes(:boot_order => current_boot_order)
    instance.update_attributes(:boot_order => new_boot_order)
    redirect_to edit_stack_path :id => stack.id
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
    stack = Stack.find params[:id]
    instance_ids = []
    stack.instances.each do |instance|
      instance_ids << instance.instance_ids
    end
    ec2.stop_instances(instance_ids: instance_ids, force: true)
    sleep(5.seconds)
    redirect_to stacks_path
  end

  def start_instances
    #flash[:progress] = "Starting Instances. This will take several minutes."
    ec2 = Account.ec2_client
    stack = Stack.find params[:id]
    stack.instances.order(:boot_order).each do |instance|
      ec2.start_instances(instance_ids: [instance.instance_id])
      sleep(instance.delay.minutes)
    end
    redirect_to stacks_path
  end
end
