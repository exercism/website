class Track::UpdateRepresenterVersion
  include Mandate

  initialize_with :track

  def call = track.update(representer_version: track.representer.version)
end
