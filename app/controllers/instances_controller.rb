class InstancesController < ApplicationController
  def index
    @instances = Instance.all
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
