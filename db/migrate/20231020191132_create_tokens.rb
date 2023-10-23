class CreateTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :key, null: false
      t.timestamp :last_used_at, null: false
      t.string :ip_address

      t.timestamps
    end
  end
end
