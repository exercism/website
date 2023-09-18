class SerializeTrackTrophies
  include Mandate

  initialize_with :track, :user

  def call
    track.trophies.map do |trophy|
      acquired_trophy = acquired_trophies.find { |at| at.trophy_id == trophy.id }
      SerializeTrackTrophy.(track, trophy, acquired_trophy)
    end
  end

  private
  memoize
  def acquired_trophies = user.acquired_trophies.where(track:)
end
