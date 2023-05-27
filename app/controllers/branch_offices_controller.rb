class BranchOfficesController < ApplicationController
   
  def index
    @branch_office = BranchOffice.new
    @branch_offices = BranchOffice.all
  end
  
  def create
    @branch_office = BranchOffice.create(branch_office_params)
  end
  
  private
  
  def branch_office_params
    params.require(:branch_office).permit(:branch_name, :branch_number, :attendance_type)
  end
  
end 