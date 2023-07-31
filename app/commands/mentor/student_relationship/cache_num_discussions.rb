class Mentor::StudentRelationship::CacheNumDiscussions
  include Mandate

  initialize_with :mentor, :student

  def call
    return unless Mentor::Discussion.between(mentor:, student:).exists?

    relationship = Mentor::StudentRelationship.create_or_find_by!(
      mentor:,
      student:
    )

    sql = Mentor::Discussion.
      joins(:solution).
      where(
        mentor_id: mentor.id,
        'solutions.user_id': student.id
      ).
      select("COUNT(*)").to_sql

    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      Mentor::StudentRelationship.where(id: relationship.id).
        update_all("num_discussions = (#{Arel.sql(sql)})")
    end
  end
end
