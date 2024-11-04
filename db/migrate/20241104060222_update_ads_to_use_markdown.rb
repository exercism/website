class UpdateAdsToUseMarkdown < ActiveRecord::Migration[7.0]
  def change
    add_column :partner_adverts, :markdown, :text, null: true
    add_column :partner_adverts, :html, :text, null: true
    change_column_null :partner_adverts, :base_text, true
    change_column_null :partner_adverts, :emphasised_text, true
  end
end
