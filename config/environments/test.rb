Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}",
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  config.action_mailer.perform_caching = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_options = {
    from: 'mail@example.com',
  }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr
  config.active_job.queue_adapter = :test

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Set a css_compressor so sassc-rails does not overwrite the compressor when
  # running the tests
  config.assets.css_compressor = nil

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true

    Bullet.n_plus_one_query_enable = false # Disable n+1 query detection
    Bullet.raise = false # Disable raising errors for warnings

    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Defect',
                        association: :property
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Defect',
                        association: :communal_area
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Defect',
                        association: :priority
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'Property',
                        association: :scheme
    Bullet.add_safelist type: :unused_eager_loading,
                        class_name: 'CommunalArea',
                        association: :scheme
  end
end
