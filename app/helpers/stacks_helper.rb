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

  def count_running_instances(stack_name)
    instance_ids = get_instance_ids(stack_name)
    resp = @ec2.describe_instances(instance_ids: instance_ids)
    reservations = resp[0]
    instance_count = 0
    running_count = 0
    instances = []
    reservations.each do |reservation|
      reservation.instances.each do |instance|
        instance_count += 1
        if instance.state.name != "stopped"&&"terminated"
          running_count += 1
        end
      end
    end
    server_state = {}
    server_state[:total] = instance_count
    server_state[:running] = running_count
    return server_state
  end

  def get_pretty_instance_count(stack_name)
    if stack_created?(stack_name)
      instance_count = count_running_instances(stack_name)
      pretty_instance_count = instance_count[:running].to_s + " of " + instance_count[:total].to_s + " running" 
    else
      pretty_server_state = "--loading--"
    end
    return pretty_instance_count
  end
  
  def all_servers_not_started?(stack_name)
    instance_count = count_running_instances(stack_name)
    instance_count[:running] < instance_count[:total]
  end

  def servers_running?(stack_name)
    instance_count = count_running_instances(stack_name)
    instance_count[:running] > 0
  end

#  def new_client
#    access_key_id = Account.all[0].access_key_id
#    secret_access_key = Account.all[0].secret_access_key
#    cloudformation = Aws::CloudFormation::Client.new(access_key_id: access_key_id, 
#                                                     secret_access_key: secret_access_key)
#    return cloudformation
#  end
end
