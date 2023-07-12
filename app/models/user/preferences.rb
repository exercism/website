class User::Preferences < ApplicationRecord
  belongs_to :user

  def self.keys = self.automation_keys + self.comments_keys + self.general_keys

  def self.automation_keys
    %i[
      auto_update_exercises
    ]
  end

  def self.comments_keys
    %i[
      allow_comments_by_default
    ]
  end

  def self.general_keys
    %i[
      theme
    ]
  end
end
