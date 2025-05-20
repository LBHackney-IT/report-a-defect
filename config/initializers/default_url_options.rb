default_domains = {
  test: 'localhost:3000',
  development: 'localhost:3000',
  staging: 'd2snsyd9d1jklu.cloudfront.net',
  production: 'lbh-report-a-defect.hackney.gov.uk',
}

DOMAIN = ENV.fetch('DOMAIN') { default_domains[Rails.env.to_sym] }
domain = URI(DOMAIN)
protocol = Rails.application.config.force_ssl ? 'https' : 'http'

ActionMailer::Base.default_url_options = { protocol: protocol, host: domain.to_s }
Rails.application.routes.default_url_options = ActionMailer::Base.default_url_options
