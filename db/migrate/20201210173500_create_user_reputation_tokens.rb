class CreateUserReputationTokens < ActiveRecord::Migration[6.1]
  def change
    # TODO: Remove
    drop_table :user_reputation_acquisitions, if_exists: true

    create_table :user_reputation_tokens do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :context, polymorphic: true, null: true, index: { name: "reason_object_index" }

      t.integer :value, null: false

      t.string :reason, null: false
      t.string :category, null: false
      t.integer :track_id, null: true

      t.string :external_link, null: true

      t.timestamps
    end
  end
end
