class SerializeApproaches
  include Mandate

  initialize_with :approaches

  def call
    eager_loaded_approaches.map do |approach|
      SerializeApproach.(approach, authors(approach), contributors(approach))
    end
  end

  private
  memoize
  def eager_loaded_approaches
    approaches.to_active_relation.
      includes(:track).to_a
  end

  def authors(approach)
    users.select { |user| approach_author_ids[approach.id]&.include?(user.id) }
  end

  def contributors(approach)
    users.select { |user| approach_contributor_ids[approach.id]&.include?(user.id) }
  end

  memoize
  def approach_author_ids
    Exercise::Approach::Authorship.
      where(approach: eager_loaded_approaches).
      pluck(:exercise_approach_id, :user_id).
      group_by(&:first).
      transform_values { |values| values.map(&:second) }
  end

  memoize
  def approach_contributor_ids
    Exercise::Approach::Contributorship.
      where(approach: eager_loaded_approaches).
      pluck(:exercise_approach_id, :user_id).
      group_by(&:first).
      transform_values { |values| values.map(&:second) }
  end

  memoize
  def users
    User.includes(:profile).
      where(id: approach_author_ids.values.flatten + approach_contributor_ids.values.flatten).
      to_a
  end

  class SerializeApproach
    include Mandate

    initialize_with :approach, :authors, :contributors

    def call
      {
        users: CombineAuthorsAndContributors.(authors, contributors).map do |user|
          SerializeAuthorOrContributor.(user)
        end,
        num_authors: authors.count,
        num_contributors: contributors.count,
        slug: approach.slug,
        title: approach.title,
        blurb: approach.blurb,
        snippet: approach.snippet,
        links: {
          self: Exercism::Routes.track_exercise_approach_path(approach.track, approach.exercise, approach)
        }
      }
    end
  end
end
