class Token < ApplicationRecord
  belongs_to :user

  validates :key, :last_used_at, :ip_address, presence: true

  def self.find_or_create_by_key( user:, key: nil, ip_address: nil)
    if token = user.tokens.find_by(key: key)
      token.mark_accessed(ip_address)
      token
    else
      create(
        user: user,
        key: generate_key,
        ip_address: ip_address,
        last_used_at: Time.current,
      )
    end
  end

  def mark_accessed(new_ip_address)
    update last_used_at: Time.current, ip_address: new_ip_address || ip_address
  end

  private

  def self.generate_key
    Base64.urlsafe_encode64(SecureRandom.random_bytes(48), padding: false)
  end
end
