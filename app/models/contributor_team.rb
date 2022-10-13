class ContributorTeam < ApplicationRecord
  extend Mandate::Memoize

  disable_sti!

  scope :for_track, ->(track) { where(track:) }

  enum type: {
    track_maintainers: 0,
    project_maintainers: 1,
    reviewers: 2
  }

  belongs_to :track, optional: true

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user

  has_many :repos, dependent: :destroy

  def type = super.to_sym

  def role_for_members
    MEMBER_ROLE_FOR_TYPES[type]
  end

  memoize
  def github_team
    Github::Team.new(github_name)
  end

  MEMBER_ROLE_FOR_TYPES = {
    track_maintainers: :maintainer,
    project_maintainers: :maintainer,
    reviewers: :reviewer
  }.freeze
  private_constant :MEMBER_ROLE_FOR_TYPES
end
