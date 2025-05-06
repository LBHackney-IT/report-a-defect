options = {
  concurrency: Integer(ENV.fetch('RAILS_MAX_THREADS', 5)),
}

Sidekiq.configure_server do |config|
  config.logger.level = Logger::WARN if Rails.env.production?
end
