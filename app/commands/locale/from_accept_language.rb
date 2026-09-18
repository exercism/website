class Locale::FromAcceptLanguage
  include Mandate

  def initialize(header, locales = LocaleRoster.served)
    @header = header
    @locales = locales
  end

  def call
    return if header.blank?

    tags.lazy.filter_map { |tag| Locale::Normalize.(tag, locales) }.first
  end

  private
  attr_reader :header, :locales

  def tags
    weighted = header.split(",").filter_map.with_index do |part, idx|
      tag, *params = part.split(";").map(&:strip)
      quality = quality_from(params)
      next if tag.blank? || tag == "*" || !quality.positive?

      [tag, -quality, idx]
    end

    weighted.sort_by { |_, quality, idx| [quality, idx] }.map(&:first)
  end

  def quality_from(params)
    q = params.find { |p| p.start_with?("q=") }
    return 1.0 unless q

    Float(q.delete_prefix("q="), exception: false) || 0.0
  end
end
