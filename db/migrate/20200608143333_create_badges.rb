class CreateBadges < ActiveRecord::Migration[6.0]
  def change
    create_table :badges do |t|
      t.string :type, unique: true

      t.timestamps
    end
  end
end
