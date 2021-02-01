class CreateUserProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :user_profiles do |t|
      t.bigint :user_id, null: false
      t.string :twitter
      t.string :website
      t.string :github
      t.string :linkedin
      t.string :medium
      t.string :location

      t.timestamps
    end
  end
end
