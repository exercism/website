class SerializeApproaches
  include Mandate

  initialize_with :approaches

  def call
    approaches_with_track.map do |approach|
      SerializeApproach.(approach, authors(approach), contributors(approach))
    end
  end

  private
  memoize
  def approaches_with_track = approaches.includes(:track).to_a

  def authors(approach)
    users.select { |user| approach_author_ids[approach.id]&.include?(user.id) }
  end

  def contributors(approach)
    users.select { |user| approach_contributor_ids[approach.id]&.include?(user.id) }
  end

  memoize
  def approach_author_ids
    Exercise::Approach::Authorship.
      where(approach: approaches_with_track).
      pluck(:exercise_approach_id, :user_id).
      group_by(&:first).
      transform_values { |values| values.map(&:second) }
  end

  memoize
  def approach_contributor_ids
    Exercise::Approach::Contributorship.
      where(approach: approaches_with_track).
      pluck(:exercise_approach_id, :user_id).
      group_by(&:first).
      transform_values { |values| values.map(&:second) }
  end

  memoize
  def users
    User.includes(:profile).
      where(id: approach_author_ids.values.flatten + approach_contributor_ids.values.flatten).
      with_attached_avatar.
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
