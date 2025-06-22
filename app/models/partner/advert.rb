class Partner::Advert < ApplicationRecord
  belongs_to :partner
  has_one_attached :light_logo
  has_one_attached :dark_logo

  enum status: { pending: 0, active: 1, out_of_budget: 2, retired: 3 }

  serialize :track_slugs, coder: JSON

  def self.for_track(track)
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
