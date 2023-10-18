class Exercise::UpdateTags
  include Mandate

  initialize_with :exercise

  def call = exercise.update(tags:)

  private
  def tags
    solution_tags = Solution::Tag.where(exercise:).distinct.pluck(:tag)
    existing_tags = Exercise::Tag.where(exercise:).where(tag: solution_tags).select(:id, :tag).to_a
    exercise_tags = existing_tags.map(&:tag)

    new_tags = (solution_tags - exercise_tags).map do |tag|
      Exercise::Tag.find_or_create_by!(tag:, exercise:)
    end

    existing_tags + new_tags
  end
end
