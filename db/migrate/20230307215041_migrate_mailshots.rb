class MigrateMailshots < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    rename_column :user_mailshots, :mailshot_id, :mailshot_slug
    change_column_null :user_mailshots, :mailshot_slug, true

    add_column :user_mailshots, :mailshot_id, :bigint

    slugs = User::Mailshot.distinct.pluck(:mailshot_slug)
    slugs.each do |slug|
      mailshot = Mailshot.create!(
        slug: slug,
        email_communication_preferences_key: "legacy",
        subject: "Legacy",
        button_url: "Legacy",
        button_text: "Legacy",
        text_content: "Legacy",
        content_markdown: "Legacy",
        content_html: "Legacy",
        test_sent: true
      )
      User::Mailshot.where(mailshot_slug: slug).update_all(mailshot_id: mailshot.id)
    end

    change_column_null :user_mailshots, :mailshot_id, false
    add_foreign_key :user_mailshots, :mailshots

    remove_index :user_mailshots, [:user_id, :mailshot_slug]
    add_index :user_mailshots, [:user_id, :mailshot_id]
  end
end
