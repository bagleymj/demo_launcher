module StacksHelper
  def get_public_ip(stack_name)
    resp = @cloudformation.list_stack_resources(stack_name: stack_name)
    resources = resp[0]
    ip_resource = resources.select{|resource| resource.logical_resource_id == 'demoPublcIP'}
    ip_address = ip_resource[0].physical_resource_id
    return ip_address
  end

#  def new_client
#    access_key_id = Account.all[0].access_key_id
#    secret_access_key = Account.all[0].secret_access_key
#    cloudformation = Aws::CloudFormation::Client.new(access_key_id: access_key_id, 
#                                                     secret_access_key: secret_access_key)
#    return cloudformation
#  end
end
