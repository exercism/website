class CreateBootcampSubmissions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :bootcamp_submissions do |t|
      t.string :uuid, null: false
      t.belongs_to :solution, foreign_key: { to_table: "bootcamp_solutions" }, null: true
      t.column :status, :smallint, null: false
      t.text :code, null: false
      t.text :readonly_ranges, null: false
      t.text :test_results, null: false

      t.timestamps
    end
  end
end
