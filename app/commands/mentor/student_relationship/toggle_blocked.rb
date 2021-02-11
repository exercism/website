module Mentor
  class StudentRelationship
    class ToggleBlocked
      include Mandate

      initialize_with :mentor, :student, :blocked

      def call
        # TODO: Don't create if they haven't had a discussion
        relationship = Mentor::StudentRelationship.create_or_find_by!(
          mentor: mentor,
          student: student
        )

        if blocked
          relationship.update_columns(blocked: true, favorited: false)
        else
          relationship.update_columns(blocked: false)
        end
      end
    end
  end
end
