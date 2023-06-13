class Exercise::Representation::CalculateCounts
  include Mandate

  initialize_with :mentor, :track_ids

  def call
    {
      without_feedback: count_for_mode(:without_feedback),
      with_feedback: count_for_mode(:with_feedback),
      admin: count_for_mode(:admin)
    }
  end

  private
  def count_for_mode(mode)
    representations = Exercise::Representation::Search.(
      mentor:,
      mode:,
      sorted: false,
      paginated: false,
      track: track_ids
    )
    representations.count
  end
end
