class Exercise::Representation::UpdatePublishedSolutions
  include Mandate

  initialize_with :representation

  def call
    representation.update(
      num_published_solutions: representation.published_solutions.count
    )

    Exercise::Representation::SyncToSearchIndex.defer(representation)
  end
end
