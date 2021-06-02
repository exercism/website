class Github::IssueLabel < ApplicationRecord
  belongs_to :issue,
    inverse_of: :labels,
    foreign_key: "github_issue_id",
    class_name: "Github::Issue"

  def self.for_type(type, val)
    return unless TYPES.include?(type)
    return unless TYPES[type].include?(val)

    "x:#{type}/#{val}"
  end

  TYPES = {
    action: %i[create fix improve proofread sync],
    knowledge: %i[none elementary intermediate advanced],
    module: %i[analyzer concept-exercise concept generator practice-exercise representer test-runner],
    size: %i[xs s m l xl],
    status: %i[claimed],
    type: %i[ci coding content docker docs]
  }.freeze
  private_constant :TYPES
end
