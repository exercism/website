module API
  class MentorStudentRelationshipsController < BaseController
    def mark_as_mentor_again
      relationship = Mentor::StudentRelationship.find(params[:id])

      render json: { relationship: SerializeMentorStudentRelationship.(relationship) }
    end

    def mark_as_dont_mentor_again
      relationship = Mentor::StudentRelationship.find(params[:id])

      render json: { relationship: SerializeMentorStudentRelationship.(relationship) }
    end
  end
end
