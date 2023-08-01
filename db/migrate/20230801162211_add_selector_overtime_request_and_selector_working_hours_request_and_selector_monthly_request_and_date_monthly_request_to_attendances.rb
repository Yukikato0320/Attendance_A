class AddSelectorOvertimeRequestAndSelectorWorkingHoursRequestAndSelectorMonthlyRequestAndDateMonthlyRequestToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :selector_overtime_request, :integer
    add_column :attendances, :selector_working_hours_request, :integer
    add_column :attendances, :selector_monthly_request, :integer
    add_column :attendances, :date_monthly_request, :date
  end
end
