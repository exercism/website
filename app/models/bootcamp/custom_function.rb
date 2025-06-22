class Bootcamp::CustomFunction < ApplicationRecord
  belongs_to :user
  serialize :tests, coder: JSONWithIndifferentAccess
  serialize :depends_on, coder: JSONWithIndifferentAccess

  scope :active, -> { where(active: true) }

  before_create do
    self.uuid = SecureRandom.compact_uuid unless uuid.present?
    self.name = "my#func_#{SecureRandom.hex(3)}" unless name.present?
    self.arity = 0 unless arity.present?
    self.code = "function #{name} do\n\n\nend" unless code.present?
    self.description = "" unless self.description.present?
    self.tests = [] unless self.tests.present?
    self.depends_on = [] unless self.depends_on.present?
  end

  def to_param = uuid
  def short_name = name.gsub(/^my#/, "")
end
