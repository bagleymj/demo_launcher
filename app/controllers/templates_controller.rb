class TemplatesController < ApplicationController

  def template_params
    params.require(:template).permit(:template_name,:template_url)
  end
end
