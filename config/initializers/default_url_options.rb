default_domains = {
  test: 'localhost:3000',
  development: 'localhost:3000',
  staging: 'lbh-report-a-defect-staging.herokuapp.com',
  production: 'lbh-report-a-defect-production.herokuapp.com',
}

DOMAIN = ENV.fetch('DOMAIN') { default_domains[Rails.env.to_sym] }
domain = URI(DOMAIN)
protocol = Rails.application.config.force_ssl ? 'https' : 'http'

ActionMailer::Base.default_url_options = { protocol: protocol, host: domain.to_s }
Rails.application.routes.default_url_options = ActionMailer::Base.default_url_options
