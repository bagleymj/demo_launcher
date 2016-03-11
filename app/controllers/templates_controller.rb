class TemplatesController < ApplicationController
  def index
    @templates = Template.all
    @title = "Template List"
  end

  def new
    @template = Template.new
    @title = "Add a new CloudFormation template"
  end

  def create
    @template = Template.new(template_params)
    #validate template
    #Add as a before_save method?
    if @template.save
      redirect_to templates_path
    else
      flash[:danger] = @template.errors.full_messages
    end

  end

  def destroy
    @template = Template.find(params[:id])
    @template.destroy
    redirect_to templates_path

  end

  def template_params
    params.require(:template).permit(:template_name,:template_url)
  end
end
