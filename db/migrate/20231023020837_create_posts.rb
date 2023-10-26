class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.text :title, null: false
      t.text :body, null: false
      t.text :slug, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamp :published_at
      t.timestamp :last_edited_at

      t.timestamps
    end
  end
end
