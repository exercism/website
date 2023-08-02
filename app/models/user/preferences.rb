class User::Preferences < ApplicationRecord
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
    ]
  end
end
