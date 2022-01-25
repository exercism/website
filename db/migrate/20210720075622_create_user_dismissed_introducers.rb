class CreateUserDismissedIntroducers < ActiveRecord::Migration[7.0]
  def change
    create_table :user_dismissed_introducers do |t|
      t.belongs_to :user, null: false, foreign_key: true

      t.string :slug, null: false

      t.index [:user_id, :slug], unique: true

      t.timestamps
    end
  end
end
