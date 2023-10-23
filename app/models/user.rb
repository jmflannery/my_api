class User < ApplicationRecord
  has_secure_password

  has_many :tokens, dependent: :destroy

  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :password, confirmation: true, length: { in: 6..72 }
  validates :password_confirmation, presence: true
end
