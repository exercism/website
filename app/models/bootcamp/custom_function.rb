class Bootcamp::CustomFunction < ApplicationRecord
  belongs_to :user
  serialize :tests, JSONWithIndifferentAccess
  serialize :depends_on, JSONWithIndifferentAccess

  scope :active, -> { where(active: true) }

  before_create do
    self.uuid = SecureRandom.compact_uuid unless uuid.present?
    self.name = "custom_function_#{user.bootcamp_custom_functions.count + 1}" unless name.present?
    self.fn_name = "my##{name}" unless code.present?
    self.fn_arity = 0 unless code.present?
    self.code = "function #{fn_name} do\n\n\nend" unless code.present?
    self.description = ""
    self.tests = []
    self.depends_on = []
  end

  def to_param = uuid
end
