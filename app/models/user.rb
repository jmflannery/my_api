class User < ApplicationRecord
  has_secure_password

  has_many :tokens,  dependent:  :destroy
  has_many :posts,   inverse_of: :user
  has_one  :profile, inverse_of: :user

  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :password, confirmation: true, length: { in: 6..72 }
  validates :password_confirmation, presence: true
end
