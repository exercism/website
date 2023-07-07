class User::ResetCache
  include Mandate

  initialize_with :user, :key

  def call
    # Some of these queries are really slow
    # so we don't want to wrap them in a pesimistic lock.
    # As user-data has an optimistic lock, it's not necessary either

    # Just update the single cache value, rather than
    # overriding the whole thing
    new_value = send("value_for_#{key}")

    # Change the lines below this once we move to Mysql 8
    # User::Data.where(id: user.data.id).update_all(
    #   cache: Arel.sql(%{
    #      JSON_MERGE_PATCH(
    #       COALESCE(`cache`, "{}"),
    #       '{"#{key}": #{new_value}}'
    #      )
    #   })
    # )

    User::Data::SafeUpdate.(user) do |data|
      # data.cache might be a hash returned when cache is
      # empty. We have to excplitely set it. Don't use merge!
      data.cache = data.cache.merge(key.to_s => new_value)
    end

    # Always return the new value
    new_value
  end

  private
  def value_for_has_unrevealed_testimonials? = user.mentor_testimonials.unrevealed.exists?
  def value_for_has_unrevealed_badges? = user.acquired_badges.unrevealed.exists?
  def value_for_has_unseen_reputation_tokens? = user.reputation_tokens.unseen.exists?
  def value_for_num_solutions_mentored = user.mentor_discussions.finished_for_student.count
  def value_for_num_testimonials = user.mentor_testimonials.not_deleted.count
  def value_for_num_published_testimonials = user.mentor_testimonials.published.count
  def value_for_num_published_solutions = user.solutions.published.count
  def value_for_mentor_satisfaction_percentage = Mentor::CalculateSatisfactionPercentage.(user)

  # This one is sloooooow!
  # But quicker joining on request than on solution
  def value_for_num_students_mentored
    user.mentor_discussions.finished_for_student.joins(:request).distinct.count(:student_id)
  end
end
