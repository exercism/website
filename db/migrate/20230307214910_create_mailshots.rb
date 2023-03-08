class CreateMailshots < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    create_table :mailshots do |t|
      t.string :slug, null: false
      t.string :email_communication_preferences_key, null: false
      t.boolean :test_sent, null: false, default: false
      t.json :sent_to_audiences

      t.string :subject, null: false

      t.string :button_url, null: false
      t.string :button_text, null: false
      t.text :text_content, null: false
      t.text :content_markdown, null: false
      t.text :content_html, null: false

      t.timestamps

      t.index :slug, unique: true
    end
  end
end
