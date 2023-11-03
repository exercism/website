class AddTagsToSubmissions < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :submissions, :tags, :json, null: true
  end
end
