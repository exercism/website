class SerializeMentorSessionExercise
  include Mandate

  initialize_with :exercise

  def call
    {
      id: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url
    }
  end
end
