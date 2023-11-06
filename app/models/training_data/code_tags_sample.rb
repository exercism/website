class TrainingData::CodeTagsSample < ApplicationRecord
  serialize :tags, JSON
  serialize :files, JSON

  belongs_to :track
  belongs_to :exercise, optional: true
  belongs_to :solution, optional: true

  enum dataset: { training: 0, validation: 1 }
  enum status: { untagged: 0, machine_tagged: 1, human_tagged: 2, community_checked: 3, admin_checked: 4 }

  before_validation on: :create do
    self.uuid = SecureRandom.compact_uuid unless self.uuid
    self.dataset = (rand < 0.9 ? :training : :validation) unless dataset

    self.exercise_id = solution.exercise_id unless exercise_id
    self.track_id = exercise.track_id unless track_id
  end

  def to_param = uuid

  def dataset = super.to_sym
  def status = super.to_sym

  def checked?
    status == :human_tagged || status == :admin_tagged
  end
end
