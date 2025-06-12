class Bootcamp::Solution < ApplicationRecord
  self.table_name = "bootcamp_solutions"

  belongs_to :user
  belongs_to :exercise, class_name: "Bootcamp::Exercise"
  has_one :project, through: :exercise
  has_many :submissions, dependent: :destroy, class_name: "Bootcamp::Submission"
  has_many :messages, class_name: "Bootcamp::ChatMessage", dependent: :destroy

  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where(completed_at: nil) }

  before_create do
    self.uuid = SecureRandom.uuid
  end

  def to_param = uuid

  def completed? = !!completed_at
  def in_progress? = !completed?
  def status = completed? ? :completed : :in_progress
end
