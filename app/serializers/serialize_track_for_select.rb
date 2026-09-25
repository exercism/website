class SerializeTrackForSelect
  include Mandate

  # Not a frozen constant: the title is locale-dependent, so it has to be
  # built per request rather than once at boot.
  def self.all_track
    {
      slug: nil,
      title: I18n.t('serializers.track_for_select.all_tracks'),
      icon_url: nil
    }
  end

  initialize_with :track

  def call
    {
      slug: track.slug,
      title: track.title,
      icon_url: track.icon_url
    }
  end
end
