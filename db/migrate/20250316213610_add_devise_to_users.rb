# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def self.up
    change_table :users do |t|
      ## Database authenticatable
      unless column_exists?(:users, :email)
        t.string :email, null: false, default: ""
      end
      
      unless column_exists?(:users, :encrypted_password)
        t.string :encrypted_password, null: false, default: ""
      end

      ## Recoverable
      unless column_exists?(:users, :reset_password_token)
        t.string :reset_password_token
      end
      
      unless column_exists?(:users, :reset_password_sent_at)
        t.datetime :reset_password_sent_at
      end

      ## Rememberable
      unless column_exists?(:users, :remember_created_at)
        t.datetime :remember_created_at
      end

      ## Confirmable
      unless column_exists?(:users, :confirmation_token)
        t.string :confirmation_token
      end
      
      unless column_exists?(:users, :confirmed_at)
        t.datetime :confirmed_at
      end
      
      unless column_exists?(:users, :confirmation_sent_at)
        t.datetime :confirmation_sent_at
      end
      
      unless column_exists?(:users, :unconfirmed_email)
        t.string :unconfirmed_email
      end

      # Add timestamps only if needed
      unless column_exists?(:users, :created_at) && column_exists?(:users, :updated_at)
        t.timestamps null: false
      end
    end

    # Add indexes only if needed
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    add_index :users, :confirmation_token, unique: true unless index_exists?(:users, :confirmation_token)
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end