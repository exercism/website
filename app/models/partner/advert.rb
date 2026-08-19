class Partner::Advert < ApplicationRecord
  belongs_to :partner
  has_one_attached :light_logo
  has_one_attached :dark_logo

  enum status: { pending: 0, active: 1, out_of_budget: 2, retired: 3 }

  serialize :track_slugs, coder: JSON

  # The chosen advert is cached for a day. The selection below is random, which
  # makes every render of a page containing an advert unique and therefore
  # impossible to cache at the CDN. Caching the decision costs us nothing now
  # that there is effectively a single active advert, and it lets the track and
  # exercise pages that render it be given a long edge TTL.
  def self.for_track(track)
    id = Rails.cache.fetch("partner/advert/for_track/#{track.slug}", expires_in: 1.day) do
      select_for_track(track)&.id
    end

    includes(
      light_logo_attachment: :blob,
      dark_logo_attachment: :blob,
      partner: [light_logo_attachment: :blob, dark_logo_attachment: :blob]
    ).find_by(id:)
  end

  def self.select_for_track(track)
    candidates = active.to_a.sort_by! { rand }

    # Sort through ones without slugs first, then ones with them.
    # rubocop:disable Style/CombinableLoops
    candidates.each do |candidate|
      next unless candidate.track_slugs

      return candidate if candidate.track_slugs.include?(track.slug)
    end

    candidates.each do |candidate|
      return candidate unless candidate.track_slugs
    end
    # rubocop:enable Style/CombinableLoops

    nil
  end
  private_class_method :select_for_track

  # Without this, an advert that is retired or goes out of budget would carry on
  # being served for up to a day. Adverts change rarely, so clearing every
  # track's key on any change is cheaper than versioning the key on read.
  def self.clear_for_track_cache!
    Track.pluck(:slug).each do |slug|
      Rails.cache.delete("partner/advert/for_track/#{slug}")
    end
  end

  after_commit { self.class.clear_for_track_cache! }

  before_create do
    self.uuid = SecureRandom.compact_uuid
  end

  before_save do
    self.html = Markdown::Parse.(markdown)
  end

  def to_param
    uuid
  end

  def show_to?(user)
    @show_to ||= {}
    @show_to[user&.id] ||= true
  end
end
