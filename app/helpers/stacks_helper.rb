module StacksHelper
  def get_public_ip(stack_name)
    resp = @cloudformation.list_stack_resources(stack_name: stack_name)
    resources = resp[0]
    ip_resource = resources.select{|resource| resource.logical_resource_id == 'demoPublcIP'}
    if ip_resource[0].nil?
      ip_address = '--loading--'
    else
      ip_address = ip_resource[0].physical_resource_id
    end
    return ip_address
  end

  def get_stack_status(stack_name)
    resp = @cloudformation.describe_stacks({stack_name: stack_name})
    stack_status = resp[0][0].stack_status
    return stack_status
  end

  def get_server_status(stack_name)
    resp = @cloudformation.list_stack_resources({stack_name: stack_name})
    resources = resp[0]
    ts_resource = resources.select{|resource| resource.logical_resource_id == 'tsInstance'}
    if !stack_created?(stack_name)
      server_status = '--loading--'
    else
      instance_id = ts_resource[0].physical_resource_id
      resp2 = @ec2.describe_instance_status({instance_ids: [instance_id]})
      server_status = resp2[0][0].system_status.status
    end
    return server_status

  end

  def stack_created?(stack_name)
    stack_status = get_stack_status(stack_name)
    stack_status == 'CREATE_COMPLETE'
  end

  def get_instance_ids(stack_name)
    resp = @cloudformation.list_stack_resources({stack_name: stack_name})
    resources = resp[0]
    instance_resources = resources.select{|resource| resource.resource_type == 'AWS::EC2::Instance'}
    instance_ids = []
    instance_resources.each do |instance|
      instance_ids << instance.physical_resource_id
    end
    return instance_ids
  end
  

#  def new_client
#    access_key_id = Account.all[0].access_key_id
#    secret_access_key = Account.all[0].secret_access_key
#    cloudformation = Aws::CloudFormation::Client.new(access_key_id: access_key_id, 
#                                                     secret_access_key: secret_access_key)
#    return cloudformation
#  end
end
