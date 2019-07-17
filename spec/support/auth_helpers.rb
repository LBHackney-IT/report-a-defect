module AuthHelpers
  def stub_global_auth(return_value: true)
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate?)
      .and_return(return_value)
  end

  def stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: 'foo',
                                env_value_for_password: 'bar')
    fake_env = double.as_null_object
    allow(Figaro).to receive(:env).and_return(fake_env)
    allow(fake_env).to receive(env_field_for_username.to_sym).and_return(env_value_for_username)
    allow(fake_env).to receive(env_field_for_password.to_sym).and_return(env_value_for_password)
  end

  def mock_successful_authentication(uid: '12345', name: 'Alex')
    OmniAuth.config.mock_auth[:auth0] = OmniAuth::AuthHash.new(
      provider: 'auth0',
      uid: uid,
      info: {
        name: name,
      }
    )
  end

  def stub_authenticated_session(name: 'Alex')
    page.set_rack_session(userinfo: { uid: '123456789', info: { name: name } })
  end
end

RSpec.shared_examples 'basic auth' do
  context 'when the path is root' do
    let(:path) { '/' }

    it 'returns 401 and asks for the basic auth credentials' do
      get path
      expect(response).to have_http_status(401)
    end

    context 'when the correct basic auth credentials are given' do
      it 'returns a 200' do
        username = 'username'
        password = 'foobar'

        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: username,
                                  env_value_for_password: password)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)

        get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }

        expect(response).to have_http_status(200)
      end
    end

    context 'when the incorrect basic auth credentials are given' do
      it 'returns a 401' do
        stub_env_for_staging_auth(env_field_for_username: :http_user,
                                  env_field_for_password: :http_pass,
                                  env_value_for_username: nil,
                                  env_value_for_password: nil)

        encoded_credentials = ActionController::HttpAuthentication::Basic.encode_credentials('wrong-user', 'password')
        get path, env: { 'HTTP_AUTHORIZATION': encoded_credentials }
        expect(response).to have_http_status(401)
      end
    end
  end
end

RSpec.shared_examples 'no basic auth' do
  context 'when the path is root' do
    it 'returns a 200' do
      stub_env_for_staging_auth(env_field_for_username: :http_user,
                                env_field_for_password: :http_pass,
                                env_value_for_username: nil,
                                env_value_for_password: nil)
      get '/'

      expect(response).to have_http_status(200)
    end
  end
end
