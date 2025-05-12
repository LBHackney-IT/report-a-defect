redis_url = "#{ENV['REDIS_URL']}/0"

options = {
  concurrency: Integer(ENV.fetch('RAILS_MAX_THREADS', 5)),
}

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    size: options[:concurrency] + 5,
    name: 'primary',
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
    size: options[:concurrency] + 5,
    name: 'primary',
  }
end

Sidekiq.configure_server do |config|
  config.logger.level = Logger::WARN if Rails.env.production?
end
