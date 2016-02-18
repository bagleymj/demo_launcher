class StacksController < ApplicationController
  def index
    @stacks = Stack.all
    @cloudformation = new_client
  end


  def new
    @stack = Stack.new
  end


  def create
    @stack = Stack.new(stack_params)
    stack_name = @stack.stack_name
    template_url = Account.all[0].template_url
    cloudformation = new_client
    new_stack = cloudformation.create_stack(stack_name: stack_name, template_url: template_url)
    if new_stack.empty?
      render :new
    else
      @stack.stack_id = new_stack[:stack_id]
      if @stack.save
        redirect_to stacks_path
      else
        render :new
      end
    end
  end

  def show
    @stack = Stack.find(params[:id])
    stack_name = @stack.stack_name
    cloudformation = new_client
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
    @standard_volumes = volumes.select{|volume| volume[:volume_type] == 'standard'}

    

    
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
    cloudformation.delete_stack(stack_name: stack_name)
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

end