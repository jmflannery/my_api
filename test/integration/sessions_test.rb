require 'test_helper'

describe 'Sessions' do
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file('config.ru')
  end

  describe 'Sign In' do
    let(:current_user) { create(:user) }
    let(:credentials) {{ email: current_user.email, password: current_user.password }}

    describe 'Given a valid email and correct password' do
      it 'should sign in the user' do
        post '/sessions', credentials
        user = JSON.parse(last_response.body)
        expect(last_response.status).must_equal 201
        expect(last_response.cookies['api_key']).must_be :present?
        expect(last_response.cookies['api_key'][0].length).must_equal 64
        expect(user['id']).must_equal current_user.id
      end

      describe 'with no authentication cookie included' do
        it 'should create a Token' do
          post '/sessions', credentials
          expect(current_user.reload.tokens.first).must_be :present?
        end
      end

      describe 'with an authentication cookie included' do
        before do
          sign_in current_user
        end

        it 'should find and update the Token' do
          previously_used_at = @token.last_used_at
          post '/sessions', credentials
          expect(last_response.cookies['api_key'].value[0]).must_equal @token.key
          expect(@token.reload.last_used_at).must_be :>, previously_used_at
          expect(@token.ip_address).must_equal '127.0.0.1'
        end
      end
    end

    describe 'Given a valid email and incorrect password' do
      it 'should not sign in the user' do
        post '/sessions', email: current_user.email, password: 'wrong-password'
        expect(last_response.status).must_equal 401
        expect(last_response.cookies['api_key']).wont_be :present?
      end
    end
  end
end
