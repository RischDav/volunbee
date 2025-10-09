web: bundle exec puma -C config/puma.rb
release: echo "Starting migrations..." && bundle exec rake db:migrate VERBOSE=true && echo "Migrations completed" && bundle exec rake assets:precompile
