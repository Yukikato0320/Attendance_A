class AddStartedAtBeforeAndFinishedAtBeforeAndStartedAtEditedAndFinishedAtEditedAndEstimatedOvertimeHoursToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_at_before, :datetime
    add_column :attendances, :finished_at_before, :datetime
    add_column :attendances, :started_at_edited, :datetime
    add_column :attendances, :finished_at_edited, :datetime
    add_column :attendances, :estimated_overtime_hours, :datetime
  end
end
