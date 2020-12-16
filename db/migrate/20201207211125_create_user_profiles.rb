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
    
    add_column :users, :bio, :text, null: true

    User.update_all(bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.")
    User.first&.update(name: "Erik ShireBOOM")
    User.first&.create_profile(
      location: "Bree, Middle Earth",
      github: "iHiD",
      twitter: "iHiD",
      linkedin: "iHiD",
      medium: "iHiD",
      website: "https://ihid.info"
    )
  end
end
