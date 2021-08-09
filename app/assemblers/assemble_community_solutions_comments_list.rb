class AssembleCommunitySolutionsCommentsList
  include Mandate

  initialize_with :solution, :user

  def call
    { comments: SerializeSolutionComments.(solution.comments, user) }
  end
end
