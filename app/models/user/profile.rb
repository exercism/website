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
    user.mentor_testimonials.published.count.positive?
  end

  memoize
  def contributions_tab?
    user.reputation_tokens.where(category: %i[building authoring maintaining misc]).exists?
  end

  memoize
  def badges_tab?
    user.revealed_badges.exists?
  end
end
