class SerializeTrackTrophy
  include Mandate

  initialize_with :track, :trophy, :acquired_trophy

  def call
    {
      name: trophy.name(track),
      criteria: trophy.criteria(track),
      success_message: trophy.success_message(track),
      icon_name: trophy.icon,
      num_awardees: trophy.num_awardees,
      awarded_at: acquired_trophy&.created_at&.iso8601,
      status:,
      links:,
      track: {
        title: track.title
      }
    }
  end

  private
  def status
    return :not_earned if acquired_trophy.nil?
    return :revealed if acquired_trophy.revealed

    :unrevealed
  end

  def links
    return {} if acquired_trophy.nil? || acquired_trophy.revealed

    {
      reveal: Exercism::Routes.reveal_api_track_trophy_url(track.slug, acquired_trophy.uuid)
    }
  end
end
