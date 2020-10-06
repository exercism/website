class Track::Concept < ApplicationRecord
  extend FriendlyId

  friendly_id :slug, use: [:history]

  belongs_to :track
end
