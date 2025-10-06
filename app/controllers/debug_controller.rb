class DebugController < ApplicationController
    skip_before_action :authenticate_user!

  def schema
    render json: {
      positions_columns: Position.column_names,
      users_columns: User.column_names,
      organizations_columns: Organization.column_names,
      migration_status: ActiveRecord::Base.connection.execute("SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 10").to_a,
      pending_migrations: ActiveRecord::MigrationContext.new(Rails.application.paths["db/migrate"].first, ActiveRecord::SchemaMigration).needs_migration?,
      current_version: ActiveRecord::Migrator.current_version
    }
    }
  end
end