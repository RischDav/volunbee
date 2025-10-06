class DebugController < ApplicationController
  def schema
    render json: {
      positions_columns: Position.column_names,
      users_columns: User.column_names,
      organizations_columns: Organization.column_names,
      migration_status: ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 10").to_a
    }
  end
end