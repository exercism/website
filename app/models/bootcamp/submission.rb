class Bootcamp::Submission < ApplicationRecord
  self.table_name = "bootcamp_submissions"

  serialize :test_results, JSONWithIndifferentAccess
  serialize :readonly_ranges, JSONWithIndifferentAccess
  serialize :custom_functions, JSONWithIndifferentAccess
  enum :status, { pass: 0, fail: 1, pass_bonus: 2, unknown: 3 }

  scope :passed, -> { where(status: :pass) }
  scope :passed_bonus, -> { where(status: :pass_bonus) }
  scope :failed, -> { where(status: :fail) }

  belongs_to :solution, class_name: "Bootcamp::Solution"

  before_create do
    self.uuid = SecureRandom.uuid
    self.status = test_results[:status]
    self.custom_functions = [] unless custom_functions.present?
  end

  def status = super.to_sym
  def passed? = status == :pass
  def passed_bonus? = status == :pass_bonus
  def test_suite = test_results[:suite].to_sym

  def passed_test?(slug)
    test = test_results[:tests].find { |tr| tr[:slug] == slug.to_s }
    return false unless test

    test[:status].to_s == "pass"
  end
end
