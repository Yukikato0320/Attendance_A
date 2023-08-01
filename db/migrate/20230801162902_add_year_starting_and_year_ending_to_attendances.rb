class AddYearStartingAndYearEndingToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :year_starting, :datetime
    add_column :attendances, :year_ending, :datetime
  end
end
