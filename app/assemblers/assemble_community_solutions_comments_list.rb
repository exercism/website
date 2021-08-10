class AssembleCommunitySolutionsCommentsList
  include Mandate

  initialize_with :solution, :user

  def call
    { items: SerializeSolutionComments.(solution.comments, user) }
  end
end
