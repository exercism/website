class Github::IssueLabel < ApplicationRecord
  belongs_to :issue,
    inverse_of: :labels,
    foreign_key: "github_issue_id",
    class_name: "Github::Issue"

  %w[action knowledge module size status type].each do |label|
    define_singleton_method "for_#{label}" do |val|
      return unless const_get(label.pluralize.upcase.to_sym).include?(val)

      "x:#{label}/#{val.to_s.tr('_', '-')}"
    end
  end

  ACTIONS = %i[create fix improve proofread sync].freeze
  KNOWLEDGES = %i[none elementary intermediate advanced].freeze
  MODULES = %i[analyzer concept_exercise concept generator practice_exercise representer test_runner].freeze
  SIZES = %i[xs s m l xl].freeze
  STATUSES = %i[claimed].freeze
  TYPES = %i[ci coding content docker docs].freeze
  private_constant :ACTIONS, :KNOWLEDGES, :MODULES, :SIZES, :STATUSES, :TYPES
end
