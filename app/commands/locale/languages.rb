class Locale::Languages
  include Mandate

  Language = Struct.new(:code, :native, :english, :flag, keyword_init: true)

  # Flag basenames in app/images/flags/3x2, named by country and not by
  # language: several languages share a flag, and the two spoken too widely for
  # one country to be honest share the world flag.
  FLAGS = {
    "en" => "gb",
    "ar" => "world",
    "bn" => "bd",
    "ca" => "ad",
    "de" => "de",
    "el" => "gr",
    "es-419" => "world",
    "es-ES" => "es",
    "fa" => "ir",
    "fi" => "fi",
    "fr" => "fr",
    "he" => "il",
    "hi" => "in",
    "hu" => "hu",
    "id" => "id",
    "it" => "it",
    "ja" => "jp",
    "ko" => "kr",
    "nl" => "nl",
    "pl" => "pl",
    "pt-BR" => "br",
    "pt-PT" => "pt",
    "ro" => "ro",
    "ru" => "ru",
    "sr" => "rs",
    "sv" => "se",
    "sw" => "tz",
    "th" => "th",
    "tr" => "tr",
    "uk" => "ua",
    "ur" => "pk",
    "vi" => "vn",
    "zh-CN" => "cn",
    "zh-TW" => "tw"
  }.freeze

  DEFAULT_FLAG = "world".freeze

  initialize_with :current_locale

  def call = { live:, coming_soon: }

  private
  # The language being read leads, then English as the fallback everyone can
  # read, then the display order.
  def live
    languages = sorted(served)
    pinned = [current_locale.to_s, I18n.default_locale.to_s].uniq

    pinned.filter_map { |code| languages.find { |language| language.code == code } } +
      languages.reject { |language| pinned.include?(language.code) }
  end

  # Everything Exercism is being translated into and does not serve yet.
  def coming_soon = sorted(Locale::Name::NAMES.keys - served)

  def served = I18n.available_locales.map(&:to_s)

  def sorted(codes) = codes.map { |code| language(code) }.sort_by { |language| sort_key(language) }

  # Rows lead with the endonym, so the list is sorted on the endonym. That only
  # works inside one alphabet, so names in other scripts settle at the bottom as
  # their own run, ordered by English name.
  def sort_key(language)
    return [1, "", language.english] unless latin?(language.native)

    [0, language.native.downcase, language.english]
  end

  def latin?(name) = /\A\p{Latin}/.match?(name)

  def language(code)
    name = Locale::Name.(code)
    Language.new(code:, native: name.native, english: name.english, flag: FLAGS.fetch(code, DEFAULT_FLAG))
  end
end
