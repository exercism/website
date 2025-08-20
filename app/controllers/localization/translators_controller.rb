class Localization::TranslatorsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new]

  def show; end

  def new
    @locale_options = LOCALE_OPTIONS.map { |flag, word, locale| ["#{flag} #{word}", locale] }
  end

  def create
    locales = params[:locales].map(&:presence).compact
    current_user.update!(translator_locales: locales)

    redirect_to action: :new
  end

  LOCALE_OPTIONS = [
    ["🇦🇪", "العربية", "ar"],
    ["🇧🇩", "বাংলা", "bn"],
    ["🇧🇾", "Беларуская", "be"],
    ["🇧🇬", "Български", "bg"],
    ["🇷🇺", "Русский", "ru"],
    ["🇷🇸", "Српски", "sr"],
    ["🇲🇰", "Македонски", "mk"],
    ["🇺🇦", "Українська", "uk"],
    ["🇰🇿", "Қазақ тілі", "kk"],
    ["🇦🇲", "Հայերեն", "hy"],
    ["🇬🇷", "Ελληνικά", "el"],
    ["🇮🇷", "فارسی", "fa"],
    ["🇮🇱", "עברית", "he"],

    ["🇮🇳", "हिन्दी", "hi"],
    ["🇮🇳", "मराठी", "mr"],
    ["🇮🇳", "తెలుగు", "te"],
    ["🇮🇳", "தமிழ்", "ta"],
    ["🇮🇳", "മലയാളം", "ml"],
    ["🇮🇳", "ଓଡ଼ିଆ", "or"],
    ["🇮🇳", "ગુજરાતી", "gu"],
    ["🇮🇳", "ಕನ್ನಡ", "kn"],

    ["🇵🇰", "اردو", "ur"],
    ["🇵🇰", "پنجابی", "pa"],
    ["🇵🇰", "پښتو", "ps"],

    ["🇰🇭", "ខ្មែរ", "km"],
    ["🇱🇦", "ລາວ", "lo"],
    ["🇳🇵", "नेपाली", "ne"],

    ["🇨🇳", "简体中文", "zh-CN"],
    ["🇹🇼", "繁體中文", "zh-TW"],

    ["🇮🇩", "ꦧꦱꦗꦮ", "jv"],

    ["🇯🇵", "日本語", "ja"],
    ["🇰🇷", "한국어", "ko"],
    ["🇹🇯", "Тоҷикӣ", "tg"],
    ["🇰🇬", "Кыргызча", "ky"],
    ["🇬🇪", "ქართული", "ka"],
    ["🇲🇳", "Монгол", "mn"],
    ["🇿🇦", "Afrikaans", "af"],
    ["🇪🇹", "Amharic", "am"],
    ["🇦🇿", "Azərbaycanca", "az"],
    ["🇮🇩", "Bahasa Indonesia", "id"],
    ["🇲🇾", "Bahasa Melayu", "ms"],
    ["🇧🇦", "Bosanski", "bs"],
    ["🇪🇸", "Català", "ca"],
    ["🇨🇿", "Čeština", "cs"],
    ["🇲🇪", "Crnogorski", "sr-ME"],
    ["🇬🇧", "Cymraeg", "cy"],
    ["🇩🇰", "Dansk", "da"],
    ["🇦🇫", "Dari", "prs"],
    ["🇩🇪", "Deutsch", "de"],
    ["🇪🇪", "Eesti", "et"],
    ["🇬🇧", "English", "en"],
    ["🇪🇸", "Español", "es"],
    ["🇪🇸", "Euskara", "eu"],
    ["🇵🇭", "Filipino", "fil"],
    ["🇫🇷", "Français", "fr"],
    ["🇮🇪", "Gaeilge", "ga"],
    ["🇼🇸", "Gagana Sāmoa", "sm"],
    ["🇬🇱", "Galego", "gl"],
    ["🇳🇬", "Hausa", "ha"],
    ["🇭🇷", "Hrvatski", "hr"],
    ["🇳🇬", "Igbo", "ig"],
    ["🇮🇸", "Íslenska", "is"],
    ["🇮🇹", "Italiano", "it"],
    ["🇰🇪", "Kiswahili", "sw"],
    ["🇵🇰", "Kurdî", "ku"],
    ["🇱🇻", "Latviešu", "lv"],
    ["🇱🇺", "Lëtzebuergesch", "lb"],
    ["🇱🇹", "Lietuvių", "lt"],
    ["🇭🇺", "Magyar", "hu"],
    ["🇲🇬", "Malagasy", "mg"],
    ["🇲🇹", "Malti", "mt"],
    ["🇳🇿", "Māori", "mi"],
    ["🇳🇱", "Nederlands", "nl"],
    ["🇳🇴", "Norsk", "no"],
    ["🇺🇿", "Oʻzbekcha", "uz"],
    ["🇮🇳", "Oromo", "om"],
    ["🇵🇱", "Polski", "pl"],
    ["🇧🇷", "Português Brasileiro", "pt-BR"],
    ["🇵🇹", "Português Europeu", "pt-PT"],
    ["🇵🇰", "Punjabi (Gurmukhi)", "pa-IN"],
    ["🇵🇪", "Quechua", "qu"],
    ["🇷🇴", "Română", "ro"],
    ["🇱🇸", "Sesotho", "st"],
    ["🇿🇼", "Shona", "sn"],
    ["🇦🇱", "Shqip", "sq"],
    ["🇵🇰", "Sindhi", "sd"],
    ["🇸🇰", "Slovenčina", "sk"],
    ["🇸🇮", "Slovenščina", "sl"],
    ["🇸🇴", "Soomaali", "so"],
    ["🇫🇮", "Suomi", "fi"],
    ["🇸🇪", "Svenska", "sv"],
    ["🇻🇳", "Tiếng Việt", "vi"],
    ["🇹🇷", "Türkçe", "tr"]
  ].freeze
end
