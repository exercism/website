class ContributorTeam < ApplicationRecord
  disable_sti!

  enum type: {
    track_maintainers: 0,
    reviewers: 1
  }

  belongs_to :track, optional: true

  has_many :memberships, dependent: :destroy
  has_many :members, through: :team_memberships, source: :user

  def type
    super.to_sym
  end
end
