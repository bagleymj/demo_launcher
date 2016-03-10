class TemplatesController < ApplicationController
  def index
    @templates = Template.all
    @title = "Template List"
  end

  def new

  end

  def create

  end

  def destroy

  end

  def template_params
    params.require(:template).permit(:template_name,:template_url)
  end
end
