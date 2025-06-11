class User::Profile < ApplicationRecord
  extend Mandate::Memoize
  include CachedFind

  MIN_REPUTATION = 5

  belongs_to :user

  delegate :to_param, to: :user

  memoize
  def solutions_tab? = user.num_published_solutions > 3

  memoize
  def testimonials_tab? = user.num_published_testimonials.positive?

  memoize
  def contributions_tab?
    user.reputation_tokens.where(category: %i[building authoring maintaining misc]).exists?
  end

  memoize
  def badges_tab? = user.revealed_badges.exists?
end
