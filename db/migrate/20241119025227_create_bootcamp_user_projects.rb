class CreateBootcampUserProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :bootcamp_user_projects do |t|
      t.belongs_to :user
      t.belongs_to :project
      t.integer :status, default: 0, null: false
      
      t.timestamps
      
      t.index [:user_id, :project_id], unique: true

      t.foreign_key :users, column
      t.foreign_key :bootcamp_projects, column: :project_id
    end
  end
end
