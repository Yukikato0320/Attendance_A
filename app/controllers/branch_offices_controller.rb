class BranchOfficesController < ApplicationController
  before_action :admin_user
  
  
  def index
    @branch_office = BranchOffice.new
    @branch_offices = BranchOffice.all
  end
  
  def create
    @branch_office = BranchOffice.create(branch_office_params)
    flash[:success] = "#{@branch_office.branch_office_name}のデータを作成しました。"
    redirect_to branch_offices_path
  end
  
  
  def edit
    @branch_office = BranchOffice.find(params[:id])
  end
  
  
  def update
    @branch_office = BranchOffice.find(params[:id])
    if @branch_office.update(branch_office_params)
      flash[:success] = '編集に成功しました。'
      redirect_to branch_office_path
    else
      flash[:danger] = '編集に失敗しました。'
      render :index
    end
  end
  
  
  def destroy
    @branch_office = BranchOffice.find(params[:id])
    @branch_office.destroy
    flash[:success] = "#{@branch_office.branch_office_name}のデータを削除しました。"
    redirect_to branch_offices_path
  end
  
  
  private
  
  
  def branch_office_params
    params.require(:branch_office).permit(:branch_office_name, :branch_office_number, :attendance_type)
  end
  
end 