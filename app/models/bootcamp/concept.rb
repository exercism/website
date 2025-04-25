class Bootcamp::Concept < ApplicationRecord
  self.table_name = "bootcamp_concepts"

  has_markdown_field :content

  belongs_to :parent, optional: true, class_name: "Bootcamp::Concept"
  has_many :descendants, class_name: "Bootcamp::Concept", foreign_key: :parent_id, dependent: :nullify, inverse_of: :parent

  belongs_to :level, foreign_key: :level_idx, primary_key: :idx, inverse_of: :exercises, class_name: "Bootcamp::Level"

  has_many :exercise_concepts, dependent: :destroy, class_name: "Bootcamp::ExerciseConcept"
  has_many :exercises, through: :exercise_concepts, class_name: "Bootcamp::Exercise"

  scope :apex, -> { where(apex: true) }
  scope :non_apex, -> { where(apex: false) }

  scope :part_1, -> { where(level_idx: 1..10) }
  scope :part_2, -> { where(level_idx: 11..20) }

  scope :unlocked, -> { where('level_idx <= ?', Bootcamp::Settings.level_idx) }
  scope :locked, -> { where('level_idx > ?', Bootcamp::Settings.level_idx) }

  def to_param = slug

  def parents
    parent ? parent.parents + [parent] : []
  end
end
