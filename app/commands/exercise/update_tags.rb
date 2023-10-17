class Exercise::UpdateTags
  include Mandate

  initialize_with :exercise

  def call = exercise.update(tags:)

  private
  def tags
    Solution::Tag.where(exercise:).pluck(:tag).map do |tag|
      Exercise::Tag.find_or_create_by!(tag:, exercise:)
    end
  end
end
