class CommunityVideo < ApplicationRecord
  enum platform: { youtube: 1, vimeo: 2 }
  belongs_to :track, optional: true
  belongs_to :exercise, optional: true
  belongs_to :author, optional: true

  belongs_to :submitted_by

  def platform = super.to_sym
end
