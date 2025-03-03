class CreateBootcampCustomFunctions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_custom_functions do |t|
      t.string :uuid, null: false, index: { unique: true }

      t.belongs_to :user, null: false, foreign_key: true

      t.string :name, null: false
      t.boolean :active, null: false, default: false
      t.text :description, null: false
      t.text :code, null: false
      t.longtext :tests, null: false
      
      t.string :fn_name, null: false
      t.integer :arity, null: false

      t.timestamps
    end
  end
end
