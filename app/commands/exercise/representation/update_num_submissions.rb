class Exercise::Representation::UpdateNumSubmissions
  include Mandate

  queue_as :default

  initialize_with :representation

  def call
    # We're updating in a single query instead of two queries to avoid race-conditions
    # and using read_committed to avoid deadlocks
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      Exercise::Representation.
        where(id: representation.id).
        update_all("num_submissions = (#{num_submissions_sql})")
    end
  end

  private
  def num_submissions_sql
    Arel.sql(representation.submission_representations.select("COUNT(DISTINCT(submission_id))").to_sql)
  end
end
