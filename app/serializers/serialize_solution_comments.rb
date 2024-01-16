class SerializeSolutionComments
  include Mandate

  initialize_with :comments, :for_user

  def call
    comments.
      includes(
        :author,
        solution: { exercise: :track }
      ).
      map { |comment| SerializeSolutionComment.(comment, for_user) }
  end
end
