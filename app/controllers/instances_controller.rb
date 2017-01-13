class InstancesController < ApplicationController
  def index
    @instances = Instance.all
  end

  def new
    stack = Stack.find(params[:stack_id])
    @instance = Instance.new
    @title = "Add Instance to #{stack.stack_name}"
    company_name = stack.company.company_name
    ec2 = Account.ec2_client
    resp = ec2.describe_instances(filters:[{name: "tag:Company", 
                                           values:[company_name]}])
    reservations = resp[0]
    instance_names = []
    reservations.each do |reservation|
      reservation.instances.each do |instance|
        tags = instance.tags
        instance_name = tags.select {|tag| tag.key == 'Name'}[0].value
        instance_names << instance_name
      end
    end
    @instance_names = instance_names



  end

  def create

  end

  def stop_instance
    ec2 = Account.ec2_client
    instance = Instance.find(params[:id])
    ec2.stop_instances(instance_ids: [instance.instance_id])
    redirect_to stack_url :id => params[:stack_id]
  end

  def start_instance
    ec2 = Account.ec2_client
    instance = Instance.find(params[:id])
    ec2.start_instances(instance_ids: [instance.instance_id])
    redirect_to stack_url :id => params[:stack_id]
  end
end
