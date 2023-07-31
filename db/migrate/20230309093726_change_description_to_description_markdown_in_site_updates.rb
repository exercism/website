class ChangeDescriptionToDescriptionMarkdownInSiteUpdates < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :site_updates, :description_markdown, :text, null: true
      add_column :site_updates, :description_html, :text, null: true
      change_column_null :site_updates, :description, true

      SiteUpdate.update_all('description_markdown = description')

      SiteUpdate.where.not(description_markdown: nil).each do |site_update|
        site_update.update(description_html: Markdown::Parse.(site_update.description_markdown))
      end
    end
  end
end

