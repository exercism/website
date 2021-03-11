class SerializeMentorSessionExercise
  include Mandate

  initialize_with :exercise

  def call
    {
      id: exercise.slug,
      title: exercise.title,
      icon_name: exercise.icon_name
    }
  end
end
