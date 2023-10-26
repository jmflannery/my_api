class Post < ApplicationRecord
  belongs_to :user, inverse_of: :posts

  before_save :update_last_edited_at, if: :will_save_change_to_body?

  validates :title, :body, :slug, presence: true

  scope :published, ->(cutoff = Time.current) { where('published_at <= ?', cutoff) }

  def publish!
    update! published_at: Time.current
  end

  def unpublish!
    update! published_at: nil
  end

  private

  def update_last_edited_at
    return unless persisted?
    return if published_at.nil?

    self.last_edited_at = Time.current
  end
end
