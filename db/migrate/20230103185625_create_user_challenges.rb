class CreateUserChallenges < ActiveRecord::Migration[7.0]
  def change
    create_table :user_challenges do |t|
      t.belongs_to :user, null: false
      t.string :challenge_id, null: false

      t.timestamps

      t.index [:user_id, :challenge_id], unique: true
    end
  end
end
