class ExternalUrlNotLink < ActiveRecord::Migration[6.1]
  def change
    rename_column :user_reputation_tokens, :external_link, :external_url
  end
end
