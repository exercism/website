module Mentor
  class StudentRelationship
    class ToggleFavorite
      include Mandate

      initialize_with :mentor, :student, :favorite

      def call
        # TODO: Don't create if they haven't had a discussion
        relationship = Mentor::StudentRelationship.create_or_find_by!(
          mentor: mentor,
          student: student
        )
        relationship.update_column(:favorite, favorite)
      end
    end
  end
end
