class SerializeTasks
  include Mandate

  initialize_with :tasks

  def call
    tasks.map { |task| SerializeTask.(task) }
  end
end
