class AddConfirmableToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :confirmation_token, :string
    add_column :students, :confirmed_at, :datetime
    add_column :students, :confirmation_sent_at, :datetime
    add_column :students, :unconfirmed_email, :string
  end
end
