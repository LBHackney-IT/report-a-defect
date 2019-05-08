require 'rails_helper'

RSpec.describe 'Caching', type: :request do
  it 'returns an ok http code' do
    get '/check', headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

    expect(response).to have_http_status(:ok)
  end
end
