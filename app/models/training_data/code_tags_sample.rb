class TrainingData::CodeTagsSample < ApplicationRecord
  extend Mandate::Memoize

  serialize :tags, JSON
  serialize :llm_tags, JSON
  serialize :files, JSON

  belongs_to :track
  belongs_to :exercise, optional: true
  belongs_to :solution, optional: true
  belongs_to :locked_by, class_name: "User", optional: true

  enum dataset: { training: 0, validation: 1 }
  enum status: { untagged: 0, machine_tagged: 1, human_tagged: 2, community_checked: 3, admin_checked: 4 }

  scope :unlocked, -> { where(locked_until: nil).or(self.where('locked_until < NOW()')) }

  before_validation on: :create do
    self.uuid = SecureRandom.compact_uuid unless self.uuid
    self.dataset = (rand < 0.9 ? :training : :validation) unless dataset

    self.exercise_id = solution.exercise_id unless exercise_id
    self.track_id = exercise.track_id unless track_id
  end

  def to_param = uuid

  def dataset = super.to_sym
  def status = super.to_sym

  def safe_to_override? = %i[untagged machine_tagged].include?(status)

  def locked? = locked_until && locked_until > Time.current
  def locked_by?(user) = locked? && locked_by == user

  def lock_for_editing!(user)
    with_lock do
      return if locked_by?(user)
      raise TrainingDataCodeTagsSampleLockedError if locked?

      update!(
        locked_until: Time.current + 30.minutes,
        locked_by: user
      )
    end
  end

  def unlock!
    with_lock do
      return unless locked?

      update!(
        locked_until: nil,
        locked_by: nil
      )
    end
  end

  def next_status
    case status
    when :untagged
      :human_tagged
    when :machine_tagged
      :community_checked
    when :human_tagged
      :community_checked
    when :community_checked
      :admin_checked
    else
      status
    end
  end

  memoize
  def code = files.to_a.pluck("code").join('\n')

  def self.statuses_for_filter(filter_status)
    case filter_status
    when :needs_tagging
      :untagged
    when :needs_checking
      %i[machine_tagged human_tagged]
    when :needs_checking_admin
      :community_checked
    end
  end
end
