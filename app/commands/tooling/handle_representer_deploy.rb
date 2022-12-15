class Tooling::HandleRepresenterDeploy
  include Mandate

  queue_as :dribble

  initialize_with :track

  def call
    # TODO: update track's representer version
    # TODO: trigger re-running of representer if representer version changes
  end
end
