class Exercise::UpdateHasApproaches
  include Mandate

  queue_as :default

  initialize_with :exercise

  def call
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      exercise.update(has_approaches:)
    end

    # The exercise sync commands call this for every exercise on a force-sync,
    # so only purge when the flag genuinely moved. Community video approval
    # purges from CommunityVideo itself, which covers the case where an
    # approved video changes the dig deeper page without moving this flag.
    ::Exercise::InvalidateCloudflareCache.defer(exercise) if exercise.saved_change_to_has_approaches?
  end

  private
  def has_approaches
    exercise.community_videos.approved.exists? ||
      exercise.articles.exists? ||
      exercise.approaches.exists? ||
      exercise.approaches_introduction_exists?
  end
end
