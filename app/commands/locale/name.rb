class Locale::Name
  include Mandate

  Name = Struct.new(:native, :english, keyword_init: true)

  # Ruby has no Intl.DisplayNames, and the switcher has to render server-side
  # (the signed-out header is on pages that load no React at all), so the names
  # live here. Anything rendering them in JavaScript receives them as props.
  NAMES = {
    "en" => { native: "English", english: "English" },
    "ar" => { native: "العربية", english: "Arabic" },
    "bn" => { native: "বাংলা", english: "Bengali" },
    "ca" => { native: "català", english: "Catalan" },
    "de" => { native: "Deutsch", english: "German" },
    "el" => { native: "Ελληνικά", english: "Greek" },
    "es-419" => { native: "español latinoamericano", english: "Latin American Spanish" },
    "es-ES" => { native: "español de España", english: "European Spanish" },
    "fa" => { native: "فارسی", english: "Persian" },
    "fi" => { native: "suomi", english: "Finnish" },
    "fr" => { native: "français", english: "French" },
    "he" => { native: "עברית", english: "Hebrew" },
    "hi" => { native: "हिन्दी", english: "Hindi" },
    "hu" => { native: "magyar", english: "Hungarian" },
    "id" => { native: "Indonesia", english: "Indonesian" },
    "it" => { native: "italiano", english: "Italian" },
    "ja" => { native: "日本語", english: "Japanese" },
    "ko" => { native: "한국어", english: "Korean" },
    "nl" => { native: "Nederlands", english: "Dutch" },
    "pl" => { native: "polski", english: "Polish" },
    "pt-BR" => { native: "português do Brasil", english: "Brazilian Portuguese" },
    "pt-PT" => { native: "português europeu", english: "European Portuguese" },
    "ro" => { native: "română", english: "Romanian" },
    "ru" => { native: "русский", english: "Russian" },
    "sr" => { native: "српски", english: "Serbian" },
    "sv" => { native: "svenska", english: "Swedish" },
    "sw" => { native: "Kiswahili", english: "Swahili" },
    "th" => { native: "ไทย", english: "Thai" },
    "tr" => { native: "Türkçe", english: "Turkish" },
    "uk" => { native: "українська", english: "Ukrainian" },
    "ur" => { native: "اردو", english: "Urdu" },
    "vi" => { native: "Tiếng Việt", english: "Vietnamese" },
    "zh-CN" => { native: "简体中文", english: "Simplified Chinese" },
    "zh-TW" => { native: "繁體中文", english: "Traditional Chinese" }
  }.freeze

  initialize_with :locale

  def call = Name.new(native: entry[:native], english: entry[:english])

  private
  def entry = NAMES.fetch(locale.to_s, { native: locale.to_s, english: locale.to_s })
end
