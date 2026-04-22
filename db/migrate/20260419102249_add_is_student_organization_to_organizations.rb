class AddIsStudentOrganizationToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :is_student_organization, :boolean
  end
end