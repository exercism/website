module Mentor
  class StudentRelationship
    class CacheNumDiscussions
      include Mandate

      initialize_with :mentor, :student

      def call
        # TODO: Don't create if they haven't had a discussion
        relationship = Mentor::StudentRelationship.create_or_find_by!(
          mentor: mentor,
          student: student
        )

        sql = Solution::MentorDiscussion.
          joins(:solution).
          where(
            mentor_id: mentor.id,
            'solutions.user_id': student.id
          ).
          select("COUNT(*)").to_sql

        Mentor::StudentRelationship.where(id: relationship.id).
          update_all("num_discussions = (#{Arel.sql(sql)})")
      end
    end
  end
end
