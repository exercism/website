class CreateUserReputationTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :user_reputation_tokens do |t|
      t.string :uuid, null: false
      t.string :type, null: false

      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :exercise, foreign_key: true, null: true
      t.belongs_to :track, foreign_key: true, null: true

      t.string :uniqueness_key, null: false

      t.integer :value, null: false

      t.string :reason, null: false
      t.string :category, null: false

      t.text :params, null: false
      t.string :level, null: true
      t.integer :version, null: false
      t.text :rendering_data_cache, null: false

      t.string :external_url, null: true

      t.boolean :seen, null: false, default: false

      t.date :earned_on, null: false

      t.timestamps

      t.index %i[uniqueness_key user_id], unique: true
      t.index :earned_on, name: "sweeper"
      t.index :uuid, unique: true
    end
  end
end
