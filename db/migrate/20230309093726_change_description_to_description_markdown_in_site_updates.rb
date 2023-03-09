class ChangeDescriptionToDescriptionMarkdownInSiteUpdates < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      rename_column :site_updates, :description, :description_markdown
      add_column :site_updates, :description_html, :text, null: true

      SiteUpdate.where.not(description_markdown: nil).each do |site_update|
        site_update.update(description_html: Markdown::Parse.(site_update.description_markdown))
      end
    end
  end
end



  