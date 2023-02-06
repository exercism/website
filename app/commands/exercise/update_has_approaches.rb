class Exercise::UpdateHasApproaches
  include Mandate

  queue_as :default

  initialize_with :exercise

  def call
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      exercise.update(has_approaches:)
    end
  end

  private
  def has_approaches
    exercise.community_videos.approved.exists? ||
      exercise.articles.exists? ||
      exercise.approaches.exists? ||
      exercise.approaches_introduction_exists?
  end
end
