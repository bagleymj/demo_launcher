class InstancesController < ApplicationController
  def index
    @instances = Instance.all
  end

  def new
    @stack = Stack.find(params[:stack_id])
    @title = "Add Instances to #{@stack.stack_name}"
    company_name = @stack.company.company_name
    ec2 = Account.ec2_client
    resp = ec2.describe_instances(filters:[{name: "tag:Company", 
                                           values:[company_name]}])
    reservations = resp[0]
    saved_ids = []
    Instance.all.each do |instance|
      saved_ids << instance.instance_id
    end
    @instance_list = []
    reservations.each do |reservation|
      reservation.instances.each do |instance|
        unless saved_ids.include? instance.instance_id
          tags = instance.tags
          instance_name = tags.select {|tag| tag.key == 'Name'}[0].value
          instance_entry = Hash[:id => instance.instance_id, :name => instance_name]
          @instance_list << instance_entry
        end
      end
    end
  end

  def create
    instances = params[:instances]
    stack_id = params[:stack_id]
    instances.each do |instance|
      new_instance = Instance.new(:instance_id => instance, 
                                  :stack_id => stack_id)
      new_instance.save
    end
    redirect_to stack_path stack_id
  end

  def update
    instance = Instance.find(params[:id])
    instance.update_attributes(instance_params)
    redirect_to edit_stack_path :id => params[:stack_id]
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

  def instance_params
    params.require(:instance).permit(:delay)
  end
end
