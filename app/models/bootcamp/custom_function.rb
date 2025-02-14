class Bootcamp::CustomFunction < ApplicationRecord
  belongs_to :user
  serialize :tests, JSONWithIndifferentAccess

  before_create do
    self.uuid = SecureRandom.compact_uuid unless uuid.present?
    self.name = "Custom Function #{user.bootcamp_custom_functions.count + 1}" unless name.present?
    self.description = ""
    self.code = "" unless code.present?
    self.tests = []
    self.fn_name = "" unless code.present?
    self.fn_arity = 0 unless code.present?
  end

  def to_param = uuid
end
