class DebugController < ApplicationController
    skip_before_action :authenticate_user!

  def schema
    begin
      # Check for pending migrations using different approaches for compatibility
      pending = ActiveRecord::Base.connection.migration_context.needs_migration?
    rescue
      pending = "Unable to check"
    end
    
    render json: {
      positions_columns: Position.column_names,
      users_columns: User.column_names,
      organizations_columns: Organization.column_names,
      universities: University.all.pluck(:id, :name),
      migration_status: ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 10").to_a,
      pending_migrations: pending,
      latest_migration: ActiveRecord::Base.connection.execute("SELECT MAX(version) as latest FROM schema_migrations").first["latest"]
    }
  end
end