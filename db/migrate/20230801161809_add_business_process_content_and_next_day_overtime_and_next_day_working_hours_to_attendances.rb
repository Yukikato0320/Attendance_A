class AddBusinessProcessContentAndNextDayOvertimeAndNextDayWorkingHoursToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :business_process_content, :string
    add_column :attendances, :next_day_overtime, :boolean
    add_column :attendances, :next_day_working_hours, :boolean
  end
end
