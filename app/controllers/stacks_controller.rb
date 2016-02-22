class StacksController < ApplicationController
  def index
    @title = "AWS Stacks"
    @stacks = @current_user.stacks.all
    @cloudformation = new_client
  end


  def new
    @title = "Create New Stack"
    @stack = @current_user.stacks.new
  end


  def create
    @stack = @current_user.stacks.new(stack_params)
    stack_name = @stack.stack_name
    template_url = Account.all[0].template_url
    cloudformation = new_client
    if @stack.save
      new_stack = cloudformation.create_stack(stack_name: stack_name, template_url: template_url)
      @stack.stack_id = new_stack[:stack_id]
      redirect_to stacks_path
    else
      flash[:danger] = @stack.errors.full_messages 
      render :new
    end
   
  end

  def show
    @stack = Stack.find(params[:id])
    @title = "Resources for #{@stack.stack_name}"
    stack_name = @stack.stack_name
    cloudformation = new_client
    resp = cloudformation.list_stack_resources(stack_name: stack_name)
    @resources = resp[0]
    @standard_volumes = get_volumes(stack_name, cloudformation)

    #Find storage volumes for SX.e and Ming.le
    #sxe = @resources.select{|resource|resource[:logical_resource_id] == 'sxeInstance'}
    #sxe_id = sxe[0].physical_resource_id
    #mng = @resources.select{|resource|resource[:logical_resource_id] == 'mingleInstance'}
    #mng_id = mng[0].physical_resource_id
    #ec2 = new_ec2_client
    #resp2 = ec2.describe_volumes({
    #  filters: [
    #    {
    #      name: 'attachment.instance-id',
    #      values: [sxe_id, mng_id]
    #    }
    #  ]
    #})
    #volumes = resp2.volumes
    #@standard_volumes = volumes.select{|volume| volume[:volume_type] == 'standard'}

    

    
  end


  def edit

  end


  def update

  end


  def delete

  end


  def destroy
    @stack = Stack.find(params[:id])
    stack_name = @stack.stack_name
    cloudformation = new_client
    volumes = get_volumes(stack_name, cloudformation)
    #detach volumes
    ec2 = new_ec2_client
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
    params.require(:stack).permit(:stack_name)
  end
  
  def new_client
    access_key_id = get_access_key_id
    secret_access_key = get_secret_access_key
    cloudformation = Aws::CloudFormation::Client.new(access_key_id: access_key_id,
                                                      secret_access_key: secret_access_key)
    return cloudformation
  end

  def new_ec2_client
    access_key_id = get_access_key_id
    secret_access_key = get_secret_access_key
    ec2 = Aws::EC2::Client.new(access_key_id: access_key_id,
                               secret_access_key: secret_access_key)
    return ec2
  end

  def get_access_key_id
    access_key_id = Account.all[0].access_key_id
    return access_key_id
  end

  def get_secret_access_key
    secret_access_key = Account.all[0].secret_access_key
    return secret_access_key
  end

  def get_volumes(stack_name, cloudformation)
    resp = cloudformation.list_stack_resources(stack_name: stack_name)
    @resources = resp[0]

    #Find storage volumes for SX.e and Ming.le
    sxe = @resources.select{|resource|resource[:logical_resource_id] == 'sxeInstance'}
    sxe_id = sxe[0].physical_resource_id
    mng = @resources.select{|resource|resource[:logical_resource_id] == 'mingleInstance'}
    mng_id = mng[0].physical_resource_id
    ec2 = new_ec2_client
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


end
