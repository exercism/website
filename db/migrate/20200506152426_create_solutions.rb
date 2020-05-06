class CreateSolutions < ActiveRecord::Migration[6.0]
  def change
    create_table :solutions do |t|
      t.string :type, null: false

      t.belongs_to :user, null: false
      t.belongs_to :exercise, null: false

      t.string :uuid, null: false

      t.timestamps
    end
  end
end
