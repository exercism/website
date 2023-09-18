class Github::IssueLabel < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :issue,
    inverse_of: :labels,
    foreign_key: "github_issue_id",
    class_name: "Github::Issue"

  def self.for_type(type, val)
    return unless TYPES.include?(type)
    return unless TYPES[type].include?(val)

    "x:#{type}/#{val}"
  end

  def of_type?(type_to_check)
    return unless value && type && namespace

    namespace == :exercism &&
      type == type_to_check &&
      TYPES[type_to_check]&.include?(value)
  end

  memoize
  def value
    return unless components

    components[:value]&.to_sym
  end

  memoize
  def type
    return unless components

    components[:type]&.to_sym
  end

  memoize
  def namespace
    return unless components

    case components[:namespace]
    when 'x'
      :exercism
    else
      :unknown
    end
  end

  private
  memoize
  def components
    name.match(%r{^(?<namespace>[a-zA-z]):(?<type>[a-zA-z-]+)/(?<value>[a-zA-z-]+)$})
  end

  TYPES = {
    action: %i[create fix improve proofread sync],
    knowledge: %i[none elementary intermediate advanced],
    module: %i[analyzer concept-exercise concept generator practice-exercise representer test-runner],
    rep: %i[tiny small medium large massive],
    size: %i[tiny small medium large massive],
    status: %i[claimed],
    type: %i[ci coding content docker docs]
  }.freeze
  private_constant :TYPES
end
