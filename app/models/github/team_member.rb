class Github::TeamMember < ApplicationRecord
  belongs_to :user
  belongs_to :track, optional: true

  before_validation on: :create do
    self.track_id = Track.where(slug: team_name).pick(:id) unless track
  end
end
