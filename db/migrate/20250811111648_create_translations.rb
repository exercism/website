class CreateTranslations < ActiveRecord::Migration[7.1]
  def change
    create_table :translations do |t|
      t.string :locale, null: false
      t.string :key,    null: false
      t.text   :value
      t.text   :sample_interpolations
      t.index [:locale, :key], unique: true

      t.timestamps
    end
  end
end
