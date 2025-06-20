class CreateBootcampChatMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :bootcamp_chat_messages do |t|
      t.references :solution, null: false, foreign_key: { to_table: :bootcamp_solutions }
      t.integer :author, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
