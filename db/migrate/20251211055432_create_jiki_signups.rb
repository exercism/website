class CreateJikiSignups < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    create_table :jiki_signups do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :preferred_locale, null: false
      t.string :preferred_programming_language, null: false

      t.timestamps
    end
  end
end
