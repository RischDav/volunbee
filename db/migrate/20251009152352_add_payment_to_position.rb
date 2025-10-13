class AddPaymentToPosition < ActiveRecord::Migration[8.0]
  def change
    add_column :positions, :payment, :string
  end
end
