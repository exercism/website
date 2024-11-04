class AddMailerTextToAdverts < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?
    
    add_column :partner_adverts, :track_slugs, :text, null: true
    add_column :partner_adverts, :markdown, :text, null: true
    add_column :partner_adverts, :html, :text, null: true
    change_column_null :partner_adverts, :base_text, true
    change_column_null :partner_adverts, :emphasised_text, true
    add_column :partner_adverts, :mailer_text, :text
  end
end
