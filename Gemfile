source "https://rubygems.org"
ruby '3.2.2'

gem "rails"
gem "puma"
gem "pg"
gem "sidekiq"
gem "devise"
gem 'heroicon'

gem "mini_magick"
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "tailwindcss-rails"
gem "sprockets-rails"
gem 'sprockets', '>= 4.0.0'
gem "image_processing"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "foreman", github: "ddollar/foreman"
gem "simple_form", "~> 5.2"
gem "stimulus-rails"
gem "mail", '~> 2.7'
gem "aws-sdk-s3", require: false
gem 'dotenv-rails', groups: [:development, :test]
gem 'view_component'

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem 'listen', '~> 3.3'
end
