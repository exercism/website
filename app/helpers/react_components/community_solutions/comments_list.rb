module ReactComponents
  module CommunitySolutions
    class CommentsList < ReactComponent
      initialize_with :solution

      def to_s
        super("community-solutions-comments-list", {
          comments: SerializeSolutionComments.(solution.comments, current_user)
        })
      end
    end
  end
end
