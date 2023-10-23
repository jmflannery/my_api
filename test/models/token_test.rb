require "test_helper"

describe Token do
  let(:user) { create(:user) }
  let(:ip_address) { '127.0.0.1' }

  describe 'Create a new Token' do
    subject { Token.find_or_create_by_key(user: user, ip_address: ip_address) }

    it 'creates a valid token' do
      expect(subject.key).must_be :present?
      expect(subject.key.size).must_equal 64
    end
  end

  describe 'Find and update an existing Token by key' do
    let(:token) { create(:token, key: 'my-key', ip_address: ip_address, user: user, last_used_at: Time.current) }
    subject { Token.find_or_create_by_key(key: token.key, user: user) }

    it 'creates a valid token' do
      expect(subject.id).must_equal token.id
      expect(subject.key).must_equal token.key
      expect(subject.ip_address).must_equal token.ip_address
      expect(subject.last_used_at).must_be :>, token.last_used_at
    end
  end
end
