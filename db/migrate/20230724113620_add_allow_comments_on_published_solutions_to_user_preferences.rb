class AddAllowCommentsOnPublishedSolutionsToUserPreferences < ActiveRecord::Migration[7.0]
  def change
    return if Rails.env.production?

    add_column :user_preferences, :allow_comments_on_published_solutions, :boolean, null: false, default: false
  end
end
