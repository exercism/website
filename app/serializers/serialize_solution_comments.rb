class SerializeSolutionComments
  include Mandate

  initialize_with :comments, :for_user

  def call
    comments.
      includes(
        solution: { exercise: :track },
        author: { avatar_attachment: :blob }
      ).
      map { |comment| SerializeSolutionComment.(comment, for_user) }
  end
end
