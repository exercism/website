class CreateUserBootcampData < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    create_table :user_bootcamp_data do |t|
      t.bigint :user_id, null: false
      
      t.integer :num_views, null: false, default: 0
      t.datetime :last_viewed_at, null: true

      t.datetime :started_enrolling_at, null: true
      t.datetime :enrolled_at, null: true
      t.string :package, null: true

      t.datetime :paid_at, null: true
      t.string :payment_intent_id, null: true

      t.string :name, null: true
      t.string :email, null: true
      t.string :ppp_country, null: true

      t.timestamps
      
      t.index :user_id, unique: true
      t.foreign_key :users
    end
  end
end
