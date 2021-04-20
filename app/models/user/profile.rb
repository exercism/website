class User::Profile < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :user

  delegate :to_param, to: :user

  memoize
  def solutions_tab?
    user.solutions.published.count > 3
  end

  memoize
  def testimonials_tab?
    user.mentor_testimonials.published.count > 3
  end

  memoize
  def contributions_tab?
    user.reputation_tokens.count.positive?
  end
end
