class Tooling::Representer::HandleDeploy
  include Mandate

  queue_as :dribble

  initialize_with :track

  def call
    @old_representer_version = track.representer_version
    Track::UpdateRepresenterVersion.(track)
    reprocess_exercises!
  end

  private
  attr_reader :old_representer_version

  def reprocess_exercises!
    return if old_representer_version == track.representer_version

    Exercise::Representation::TriggerRerunsForTrack.(track)
  end
end
