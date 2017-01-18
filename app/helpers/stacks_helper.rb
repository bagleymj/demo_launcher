module StacksHelper
  def get_stack_status(stack_name)
    resp = @cloudformation.describe_stacks({stack_name: stack_name})
    stack_status = resp[0][0].stack_status
    return stack_status
  end

  def stack_created?(stack_name)
    stack_status = get_stack_status(stack_name)
    stack_status == 'CREATE_COMPLETE'
  end
  
  def get_instance_ids(stack_id)
    instance_ids = []
    stack = Stack.find(stack_id)
    stack.instances.each do |instance|
      instance_ids << instance.instance_id
    end
    return instance_ids
  end

  def get_instance_name(instance_id)
    resp = @ec2.describe_instances(instance_ids: [instance_id])
    reservations = resp[0]
    tags = reservations[0].instances[0].tags
    tags.select {|tag| tag.key == 'Name'}[0].value
  end



  def count_running_instances(stack_id)
    instance_ids = get_instance_ids(stack_id)
    resp = @ec2.describe_instances(instance_ids: instance_ids)
    reservations = resp[0]
    instance_count = instance_ids.length 
    running_count = 0
    instances = []
    reservations.each do |reservation|
      reservation.instances.each do |instance|
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

  def get_pretty_instance_count(stack_id)
    instance_count = count_running_instances(stack_id)
    pretty_instance_count = instance_count[:running].to_s + " of " + instance_count[:total].to_s + " running" 
    return pretty_instance_count
  end
  
  def all_servers_not_started?(stack_id)
    instance_count = count_running_instances(stack_id)
    instance_count[:running] < instance_count[:total]
  end

  def servers_running?(stack_id)
    instance_count = count_running_instances(stack_id)
    instance_count[:running] > 0
  end
end
