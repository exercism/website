class CommunityVideo < ApplicationRecord
  enum platform: { youtube: 1, vimeo: 2 }
  belongs_to :track, optional: true
  belongs_to :exercise, optional: true
  belongs_to :author, class_name: "User", optional: true

  belongs_to :submitted_by, class_name: "User"

  def platform = super.to_sym
end
