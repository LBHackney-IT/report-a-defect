require 'rails_helper'

RSpec.describe 'staging authentication', type: :request do
  scenario 'successful sign out' do
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(:auth0_client_id).and_return('123')
    allow(fake_env).to receive(:auth0_domain).and_return('test.auth0')
    allow(fake_env).to receive(:http_pass).and_return(nil)
    allow(fake_env).to receive(:http_user).and_return(nil)

    get '/sign_out'

    expect(request).to redirect_to('https://test.auth0/v2/logout?returnTo=http%3A%2F%2Fwww.example.com%2F&client_id=123')
  end
end
