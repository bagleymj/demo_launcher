#run using 'rails runner lib/tasks/populate_instances.rb'
# Script crawls existing stacks and writes instance data to database

cloudformation = Account.cf_client
ec2 = Account.ec2_client

stacks = Stack.all

stacks.each do |stack|
  resp_cf = cloudformation.list_stack_resources({stack_name: stack.stack_name})
  resources = resp_cf[0]
  instance_resources = resources.select{|resource| resource.resource_type == 'AWS::EC2::Instance'}
  instance_ids = []
  instance_resources.each do |instance|
    instance_ids << instance.physical_resource_id
  end
  resp_ec2 = ec2.describe_instances(instance_ids: instance_ids)
  reservations =  resp_ec2[0]
  reservations.each do |reservation|
    reservation.instances.each do |instance|
      tags = instance.tags
      instance_name = tags.select{|tag| tag.key == 'Name'}[0].value
      new_instance = Instance.new
      new_instance.instance_id = instance.instance_id
      new_instance.instance_name = instance_name
      new_instance.stack_id = stack.id
      new_instance.save
      puts "#{instance_name}(#{instance.instance_id}) successfully saved for #{stack.stack_name}"
    end
  end



end

