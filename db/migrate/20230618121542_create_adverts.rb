class CreateAdverts < ActiveRecord::Migration[7.0]
  def change
    create_table :adverts do |t|
      t.belongs_to :partner, foreign_key: true

      t.timestamps
    end
  end
end
