class Training::TrackTagsTuple < ApplicationRecord
  serialize :tags, JSON
  belongs_to :track
  belongs_to :exercise, optional: true
  belongs_to :solution, optional: true

  enum dataset: { training: 0, validation: 1 }
  enum status: { untagged: 0, machine_tagged: 1, human_tagged: 2, community_checked: 3, admin_checked: 4 }

  before_create do
    self.dataset = (rand < 0.9 ? :training : :validation) unless dataset
  end

  def dataset = super.to_sym
  def status = super.to_sym

  def checked?
    status == :human_tagged || status == :admin_tagged
  end
end
