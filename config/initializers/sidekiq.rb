redis_url = "#{ENV['REDIS_URL']}/0"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: "report_a_defect_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: "report_a_defect_#{Rails.env}" }
end
