redis_url = "#{ENV['REDIS_URL']}/0"

options = {
  concurrency: Integer(ENV.fetch('RAILS_MAX_THREADS', 5)),
}

Sidekiq.configure_server do |config|
  config.options.merge!(options)
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    size: config.options[:concurrency] + 5,
  }
end

Sidekiq.configure_client do |config|
  config.options.merge!(options)
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    size: config.options[:concurrency] + 5,
  }
end

Sidekiq.logger.level = Logger::WARN if Rails.env.production?
