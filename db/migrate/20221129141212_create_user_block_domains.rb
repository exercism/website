class CreateUserBlockDomains < ActiveRecord::Migration[7.0]
  def change
    create_table :user_block_domains do |t|
      t.string :domain, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
