class Mentor::UpdateNumSolutionsMentored
  include Mandate

  initialize_with :mentor

  def call
    # TODO: This can be removed when we remove the data from users
    # Create a data record if there's not one
    mentor.data_record

    # We're updating in a single query instead of two queries to avoid race-conditions
    # and using read_committed to avoid deadlocks
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      User::Data.where(user_id: mentor.id).update_all("num_solutions_mentored = (#{num_solutions_mentored_sql})")
    end
  end

  private
  def num_solutions_mentored_sql
    Arel.sql(Mentor::Discussion.where(mentor:).finished_for_mentor.select("COUNT(*)").to_sql)
  end
end
