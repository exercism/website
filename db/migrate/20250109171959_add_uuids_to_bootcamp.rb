class AddUuidsToBootcamp < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :bootcamp_concepts, :uuid, :string, null: true
    add_column :bootcamp_projects, :uuid, :string, null: true
    add_column :bootcamp_exercises, :uuid, :string, null: true

    # change_column_null :bootcamp_concepts, :uuid, false
    # change_column_null :bootcamp_projects, :uuid, false
    # change_column_null :bootcamp_exercises, :uuid, false

  end
end
