require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RequestARepair
  class Application < Rails::Application
    config.time_zone = 'Europe/London'

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    config.generators do |generator|
      generator.orm :active_record, primary_key_type: :uuid
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.autoloader = :classic
    
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.delivery_method = :notify
    config.action_mailer.deliver_later_queue_name = :mailers
    config.action_mailer.notify_settings = {
      api_key: ENV['NOTIFY_KEY'],
    }

    # Default host for mailers
    config.action_mailer.default_url_options = { 
      host: ENV['DOMAIN_NAME'], protocol: 'https'
    }
    # Default host for controllers
    config.action_controller.default_url_options = { 
      :host => ENV['DOMAIN_NAME'] 
    }

    config.active_record.yaml_column_permitted_classes = [Symbol,
                                                          ActiveSupport::HashWithIndifferentAccess]
  end
end
