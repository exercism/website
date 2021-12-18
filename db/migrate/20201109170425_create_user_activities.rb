class CreateUserActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :user_activities do |t|
      t.string :type, null: false

      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :track, null: true, foreign_key: true
      t.belongs_to :exercise, null: true, foreign_key: true
      t.belongs_to :solution, null: true, foreign_key: true

      t.text :params, null: false
      t.datetime :occurred_at, null: false
      t.string :uniqueness_key, null: false, index: {unique: true}

      t.integer :version, null: false
      t.text :rendering_data_cache, null: false

      t.timestamps
    end
  end
end
