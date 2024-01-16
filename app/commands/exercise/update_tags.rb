class Exercise::UpdateTags
  include Mandate

  initialize_with :exercise

  def call
    exercise.update(tags:)

    Track::UpdateTags.(exercise.track)
  end

  private
  def tags
    existing_tags = Exercise::Tag.where(exercise:).where(tag: solution_tags).select(:id, :tag).to_a
    exercise_tags = existing_tags.map(&:tag)

    new_tags = (solution_tags - exercise_tags).map do |tag|
      Exercise::Tag.find_create_or_find_by!(tag:, exercise:)
    end

    existing_tags + new_tags
  end

  memoize
  def solution_tags
    Solution::Tag.joins(:solution).where(
      exercise_id: exercise.id,
      solution: {
        status: :published,
        published_iteration_head_tests_status: :passed
      }
    ).distinct.pluck(:tag)
  end
end
