class AddChangeOvertimeAndChangeWorkingHoursAndChangeMonthlyAndStatusOvertimeAndStatusWorkingHoursAndStatusMonthlyToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_overtime, :boolean
    add_column :attendances, :change_working_hours, :boolean
    add_column :attendances, :change_monthly, :boolean
    add_column :attendances, :status_overtime, :string
    add_column :attendances, :status_working_hours, :string
    add_column :attendances, :status_monthly, :string
  end
end
