class SerializeTrackTrophies
  include Mandate

  initialize_with :track, :user

  def call
    track.trophies.map do |trophy|
      acquired_trophy = acquired_trophies.find { |at| at.trophy == trophy }
      SerializeTrackTrophy.(track, trophy, acquired_trophy)
    end
  end

  private
  memoize
  def acquired_trophies = user.acquired_trophies.where(track:)

  class SerializeTrackTrophy
    include Mandate

    initialize_with :track, :trophy, :acquired_trophy

    def call
      {
        name: trophy.name(track),
        criteria: trophy.criteria(track),
        success_message: trophy.success_message(track),
        icon_name: trophy.icon,
        status:,
        links:
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
end
