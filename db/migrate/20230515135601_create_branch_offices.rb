class CreateBranchOffices < ActiveRecord::Migration[5.1]
  def change
    create_table :branch_offices do |t|
      t.string :branch_office_name
      t.string :branch_office_number
      t.string :attendance_type

      t.timestamps
    end
  end
end
