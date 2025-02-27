class Bootcamp::CustomFunction < ApplicationRecord
  belongs_to :user
  serialize :tests, JSONWithIndifferentAccess
  serialize :depends_on, JSONWithIndifferentAccess

  scope :active, -> { where(active: true) }

  before_create do
    self.uuid = SecureRandom.compact_uuid unless uuid.present?
    self.name = "custom_function_#{user.bootcamp_custom_functions.count + 1}" unless name.present?
    self.fn_name = "my##{name}" unless fn_name.present?
    self.fn_arity = 0 unless fn_arity.present?
    self.code = "function #{fn_name} do\n\n\nend" unless code.present?
    self.description = "" unless self.description.present?
    self.tests = [] unless self.tests.present?
    self.depends_on = [] unless self.depends_on.present?
  end

  def to_param = uuid
end
