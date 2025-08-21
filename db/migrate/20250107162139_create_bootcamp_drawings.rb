class CreateBootcampDrawings < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_drawings do |t|
      t.references :user, null: false, foreign_key: true

      t.string :uuid, null: false
      t.text :code, null: false

      t.timestamps
    end
  end
end
