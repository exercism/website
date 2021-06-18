class ContributorTeam < ApplicationRecord
  disable_sti!

  scope :for_track, ->(track) { where(track: track) }

  enum type: {
    track_maintainers: 0,
    project_maintainers: 1,
    reviewers: 2
  }

  belongs_to :track, optional: true

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user

  def type
    super.to_sym
  end
end
