require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code is not reloaded between requests in production
  config.enable_reloading = false
  config.assets.compile = true
  config.assets.css_compressor = nil
  config.assets.digest = true

  config.eager_load = true
  config.consider_all_requests_local = false

  # ActiveStorage Konfiguration für direkte S3-URLs
  config.active_storage.service = :amazon
  config.active_storage.resolve_model_to_route = :rails_storage_redirect
  config.active_storage.routes_prefix = '/rails/active_storage'
  config.active_storage.variant_processor = :vips

  config.force_ssl = true

  # Logging
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Mailer
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "dashboard.volunteer-heilbronn.de", protocol: 'https' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "letsgovolunteer.com",
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    authentication: "plain",
    enable_starttls_auto: true
  }

  # I18n
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
end