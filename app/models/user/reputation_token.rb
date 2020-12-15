class User::ReputationToken < ApplicationRecord
  CATEGORIES = %i[
    building
    authoring
    mentoring
  ].freeze
  private_constant :CATEGORIES

  REASON_VALUES = {
    'authored_exercise': 10,
    'contributed_to_exercise': 5,
    'contributed_code': 10,
    'contributed_code/minor': 5,
    'contributed_code/major': 15,
    'mentored': 10,
    'reviewed_code': 3
  }.with_indifferent_access.freeze
  private_constant :REASON_VALUES

  belongs_to :user
  belongs_to :track, optional: true
  belongs_to :context, polymorphic: true, optional: true

  validates :category, inclusion: {
    in: CATEGORIES,
    message: "%<value>s is not a valid category",
    strict: ReputationTokenCategoryInvalid
  }

  validates :reason, inclusion: {
    in: REASON_VALUES.keys,
    message: "%<value>s is not a valid reason",
    strict: ReputationTokenReasonInvalid
  }

  before_save do
    self.value = REASON_VALUES[self.reason]
  end

  after_save do
    # We're updating in a single query instead of two queries to avoid race-conditions
    summing_sql = Arel.sql("(#{user.reputation_tokens.select('SUM(value)').to_sql})")
    User.where(id: user.id).update_all(reputation: summing_sql)
  end

  def category
    super.to_sym
  end
end
