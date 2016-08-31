class CompaniesController < ApplicationController
  def index
    @companies = Company.all
    @title = "Company List"
  end

  def new
    @company = Company.new
    @title = "Create New Company"
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to companies_path
    else
      render :new
    end
  end

  def show
  end

  def edit
  end
  
  def update
  end

  def destroy
  end

  def company_params
    params.require(:company).permit(:company_name)
  end
end
