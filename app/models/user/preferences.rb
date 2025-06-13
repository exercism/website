class User::Preferences < ApplicationRecord
  include CachedFind
  def self.cached_find_keys = %i[id user_id]

  belongs_to :user

  def self.keys = self.automation_keys + self.general_keys

  def self.automation_keys
    %i[
      auto_update_exercises
    ]
  end

  def self.general_keys
    %i[
      theme
      allow_comments_on_published_solutions
      hide_website_adverts
    ]
  end
end
