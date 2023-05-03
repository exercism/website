class SerializeTasks
  include Mandate

  initialize_with :tasks

  def call
    tasks.includes([:track]).
      map { |task| SerializeTask.(task) }
  end
end
