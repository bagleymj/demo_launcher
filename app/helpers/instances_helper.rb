module InstancesHelper
  def get_instance_state(instance_id)
    instance_ids = [instance_id]
    resp = @ec2.describe_instances(instance_ids: instance_ids)
    reservations = resp[0]
    instance_state = reservations[0].instances[0].state.name
    return instance_state
  end
end
