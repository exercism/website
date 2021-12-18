class CreateUserProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_profiles do |t|
      t.belongs_to :user, null: false, index: {unique: true}, foreign_key: true
      t.string :twitter
      t.string :website
      t.string :github
      t.string :linkedin
      t.string :medium

      t.timestamps
    end
  end
end
