class User::Preferences < ApplicationRecord
  belongs_to :user

  def self.keys = self.automation_keys

  def self.automation_keys
    %i[
      auto_update_exercises
      theme
    ]
  end
end
