class StacksController < ApplicationController
  def index
    @stacks = Stack.all
  end


  def new
    @stack = Stack.new
  end


  def create
    @stack = Stack.new(stack_params)
    access_key_id = Account.all[0].access_key_id
    secret_access_key = Account.all[0].secret_access_key
    stack_name = @stack.stack_name
    template_url = Account.all[0].template_url
    cloudformation = AWS::CloudFormation::Client.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
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

  end


  def edit

  end


  def update

  end


  def delete

  end


  def destroy

  end



  def stack_params
    params.require(:stack).permit(:stack_name)
  end
end
