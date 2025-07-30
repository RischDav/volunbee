class AddNameAndLastNameToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :name, :string
    add_column :students, :last_name, :string
  end
end
