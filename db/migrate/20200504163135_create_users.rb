class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :handle, null: false, unique: true
      
      t.integer :credits, limit: 2, default: 0

      t.timestamps
    end
  end
end
