class CreateUserReputationAcquisitions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_reputation_acquisitions do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :reason_object, polymorphic: true, null: true, index: {name:  "reason_object_index"}

      t.integer :amount, null: false
      t.string :category, null: false
      t.string :reason, null: false

      t.timestamps
    end
  end
end
