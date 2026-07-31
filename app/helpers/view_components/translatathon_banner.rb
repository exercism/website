module ViewComponents
  # Temporary, pre-catalog promo copy for the Big Jiki & Exercism Translatathon.
  #
  # This is the server-side sibling of the Jiki front-end's TranslatathonBanner.
  # The whole point is to reach speakers of languages we do NOT ship in the UI,
  # so its copy can't come from an i18n catalog: it lives here. The site-header
  # helper renders it as an announcement bar for signed-in users.
  #
  # It targets the first non-catalog language in the viewer's own preference list.
  # On the front-end that list is `navigator.languages`; here it's the ordered
  # `Accept-Language` request header (which encodes the same preference via q-values):
  # - a language we run in the Translatathon program (COPY below) gets the whole
  #   banner IN that language;
  # - any other non-English language we can name gets the English banner with its
  #   name filled in.
  #
  # The banner self-removes after the event (see END_TIME).
  #
  # NOTE: the translated strings below were drafted for the event and should be
  # sanity-checked by native speakers / the Translatathon translators.
  class TranslatathonBanner
    # The resolved banner to render: pre/link/post are the sentence around the
    # linked call-to-action, url is where it points, dir is "ltr" or "rtl".
    Banner = Struct.new(:pre, :link, :post, :url, :dir, keyword_init: true)

    # Where the call-to-action goes (opens in a new tab).
    TRANSLATATHON_URL = "https://i18n.jiki.io".freeze

    # The event weekend is 31 Jul - 2 Aug 2026; keep the banner up through 3 Aug.
    # After this instant it never renders. Delete the whole class once the event
    # is well past.
    END_TIME = Time.utc(2026, 8, 4)

    # Base languages we already ship in the UI: their speakers have nothing to
    # translate to, so we never show them the banner. Exercism's UI is English,
    # so English is the only catalog language.
    CATALOG_LANGUAGES = Set.new(%w[en]).freeze

    # Program languages that read right-to-left; the banner element gets dir="rtl".
    RTL_TARGETS = Set.new(%w[ar fa ur]).freeze

    # Fully-translated copy for each language in the Translatathon program, keyed by
    # the program's own locale ids. Multi-variant languages have one entry per
    # variant (es-419/es-ES, pt-BR/pt-pt, zh-CN/zh-TW); #program_locale maps a
    # browser tag to the right one. Each string is written in that language, with a
    # translated phrase for the translation session; only "Exercism" stays as a
    # proper noun.
    COPY = {
      "ar" => { pre: "هل تريد مساعدتنا في ترجمة Exercism إلى العربية؟ ", link: "انضمّ إلى جلسة الترجمة", post: "" },
      "bn" => { pre: "Exercism-কে বাংলায় অনুবাদ করতে আমাদের সাহায্য করতে চান? ", link: "অনুবাদ সেশনে যোগ দিন", post: "" },
      "ca" => { pre: "Vols ajudar-nos a traduir Exercism al català? ", link: "Uneix-te a la sessió de traducció", post: "" },
      "de" => { pre: "Möchtest du uns helfen, Exercism ins Deutsche zu übersetzen? ", link: "Mach bei der Übersetzungssession mit", post: "" }, # rubocop:disable Layout/LineLength
      "el" => { pre: "Θέλεις να μας βοηθήσεις να μεταφράσουμε το Exercism στα Ελληνικά; ", link: "Λάβε μέρος στη μεταφραστική συνεδρία", post: "" }, # rubocop:disable Layout/LineLength
      "es-419" => { pre: "¿Quieres ayudarnos a traducir Exercism al español? ", link: "Únete a la sesión de traducción", post: "" },
      "es-ES" => { pre: "¿Quieres ayudarnos a traducir Exercism al español? ", link: "Únete a la sesión de traducción", post: "" },
      "fa" => { pre: "می‌خواهید در ترجمهٔ Exercism به فارسی به ما کمک کنید؟ ", link: "به نشست ترجمه بپیوندید", post: "" },
      "fr" => { pre: "Vous voulez nous aider à traduire Exercism en français ? ", link: "Rejoignez la session de traduction", post: "" }, # rubocop:disable Layout/LineLength
      "hi" => { pre: "क्या आप Exercism का हिन्दी में अनुवाद करने में हमारी मदद करना चाहते हैं? ", link: "अनुवाद सत्र में शामिल हों", post: "" }, # rubocop:disable Layout/LineLength
      "id" => { pre: "Ingin membantu kami menerjemahkan Exercism ke Bahasa Indonesia? ", link: "Ikuti sesi terjemahan", post: "" },
      "it" => { pre: "Vuoi aiutarci a tradurre Exercism in italiano? ", link: "Partecipa alla sessione di traduzione", post: "" },
      "ja" => { pre: "Exercism を日本語に翻訳するのを手伝いませんか？", link: "翻訳セッションに参加する", post: "" },
      "ko" => { pre: "Exercism을 한국어로 번역하는 데 도움을 주시겠어요? ", link: "번역 세션에 참여하세요", post: "" },
      "nl" => { pre: "Wil je ons helpen Exercism naar het Nederlands te vertalen? ", link: "Doe mee aan de vertaalsessie", post: "" },
      "pl" => { pre: "Chcesz pomóc nam przetłumaczyć Exercism na polski? ", link: "Dołącz do sesji tłumaczeniowej", post: "" },
      "pt-BR" => { pre: "Quer nos ajudar a traduzir o Exercism para o português? ", link: "Participe da sessão de tradução", post: "" }, # rubocop:disable Layout/LineLength
      "pt-pt" => { pre: "Quer ajudar-nos a traduzir o Exercism para português? ", link: "Junte-se à sessão de tradução", post: "" },
      "ru" => { pre: "Хотите помочь нам перевести Exercism на русский? ", link: "Присоединяйтесь к сессии перевода", post: "" },
      "sr" => { pre: "Желите да нам помогнете да преведемо Exercism на српски? ", link: "Придружите се преводилачкој сесији", post: "" }, # rubocop:disable Layout/LineLength
      "sw" => { pre: "Ungependa kutusaidia kutafsiri Exercism kwa Kiswahili? ", link: "Jiunge na kikao cha tafsiri", post: "" },
      "tr" => { pre: "Exercism'i Türkçeye çevirmemize yardım etmek ister misin? ", link: "Çeviri oturumuna katıl", post: "" },
      "uk" => { pre: "Хочете допомогти нам перекласти Exercism українською? ", link: "Долучайтеся до сесії перекладу", post: "" },
      "ur" => { pre: "کیا آپ Exercism کا اردو میں ترجمہ کرنے میں ہماری مدد کرنا چاہتے ہیں؟ ", link: "ترجمے کے سیشن میں شامل ہوں", post: "" }, # rubocop:disable Layout/LineLength
      "vi" => { pre: "Bạn muốn giúp chúng tôi dịch Exercism sang Tiếng Việt? ", link: "Tham gia buổi dịch thuật", post: "" },
      "zh-CN" => { pre: "想帮我们把 Exercism 翻译成中文吗？", link: "加入翻译活动", post: "" },
      "zh-TW" => { pre: "想幫我們把 Exercism 翻譯成中文嗎？", link: "加入翻譯活動", post: "" }
    }.freeze

    # English display names for base language codes, used to fill in the English
    # fallback banner ("Want to help us translate Exercism to <name>?"). Ruby has no
    # Intl.DisplayNames, so we carry the names we care about. A code we can't name
    # gets no banner (we never render "translate Exercism to xyz").
    LANGUAGE_NAMES = {
      "af" => "Afrikaans", "am" => "Amharic", "ar" => "Arabic", "az" => "Azerbaijani",
      "be" => "Belarusian", "bg" => "Bulgarian", "bn" => "Bengali", "bs" => "Bosnian",
      "ca" => "Catalan", "cs" => "Czech", "cy" => "Welsh", "da" => "Danish",
      "de" => "German", "el" => "Greek", "es" => "Spanish", "et" => "Estonian",
      "eu" => "Basque", "fa" => "Persian", "fi" => "Finnish", "fil" => "Filipino",
      "fr" => "French", "ga" => "Irish", "gl" => "Galician", "gu" => "Gujarati",
      "he" => "Hebrew", "hi" => "Hindi", "hr" => "Croatian", "ht" => "Haitian Creole",
      "hy" => "Armenian", "id" => "Indonesian", "is" => "Icelandic", "it" => "Italian",
      "ja" => "Japanese", "ka" => "Georgian", "kk" => "Kazakh", "km" => "Khmer",
      "kn" => "Kannada", "ko" => "Korean", "lo" => "Lao", "lt" => "Lithuanian",
      "lv" => "Latvian", "mk" => "Macedonian", "ml" => "Malayalam", "mn" => "Mongolian",
      "mr" => "Marathi", "ms" => "Malay", "my" => "Burmese", "nb" => "Norwegian",
      "ne" => "Nepali", "nl" => "Dutch", "nn" => "Norwegian", "no" => "Norwegian",
      "pa" => "Punjabi", "pl" => "Polish", "pt" => "Portuguese", "ro" => "Romanian",
      "ru" => "Russian", "si" => "Sinhala", "sk" => "Slovak", "sl" => "Slovenian",
      "sq" => "Albanian", "sr" => "Serbian", "sv" => "Swedish", "sw" => "Swahili",
      "ta" => "Tamil", "te" => "Telugu", "th" => "Thai", "tl" => "Filipino",
      "tr" => "Turkish", "uk" => "Ukrainian", "ur" => "Urdu", "uz" => "Uzbek",
      "vi" => "Vietnamese", "zh" => "Chinese", "zu" => "Zulu"
    }.freeze

    def self.call(...) = new(...).()

    def initialize(accept_language_header, now: Time.current)
      @accept_language_header = accept_language_header.to_s
      @now = now
    end

    # Returns a Banner to render, or nil when nothing applies.
    def call
      return nil if now >= END_TIME

      resolve(preferred_languages)
    end

    private
    attr_reader :accept_language_header, :now

    # Walk the viewer's language list in order, take the first language we don't
    # already ship, and return either its in-program translated banner or the
    # English fallback with its name filled in. The first non-catalog language
    # decides: if we can't name it, we show nothing.
    def resolve(languages)
      languages.each do |tag|
        base = tag.split("-").first&.downcase
        next if base.nil? || CATALOG_LANGUAGES.include?(base)

        key = program_locale(tag, base)
        return program_banner(key, base) if key

        return english_banner(base)
      end
      nil
    end

    def program_banner(key, base)
      copy = COPY.fetch(key)
      Banner.new(
        pre: copy[:pre], link: copy[:link], post: copy[:post],
        url: TRANSLATATHON_URL,
        dir: RTL_TARGETS.include?(base) ? "rtl" : "ltr"
      )
    end

    # The English fallback banner for a non-program language, with the language's
    # English name filled in. Returns nil when we have no name for the code.
    def english_banner(base)
      name = LANGUAGE_NAMES[base]
      return nil unless name

      Banner.new(
        pre: "Want to help us translate Exercism to #{name}? ",
        link: "Join the Translatathon",
        post: "",
        url: TRANSLATATHON_URL,
        dir: "ltr"
      )
    end

    # Map a browser language tag to the program locale id whose copy we show, or
    # nil if the language isn't in the program. Multi-variant languages collapse by
    # region/script; every other program language is keyed by its bare base code.
    def program_locale(tag, base)
      case base
      when "es"
        region(tag) == "ES" ? "es-ES" : "es-419"
      when "pt"
        region(tag) == "PT" ? "pt-pt" : "pt-BR"
      when "zh"
        r = region(tag)
        tag.match?(/hant/i) || %w[TW HK MO].include?(r) ? "zh-TW" : "zh-CN"
      else
        COPY.key?(base) ? base : nil
      end
    end

    # The region subtag (first 2-alpha or 3-digit subtag), uppercased, or nil.
    def region(tag)
      tag.split("-").drop(1).find { |part| part.match?(/\A([A-Za-z]{2}|\d{3})\z/) }&.upcase
    end

    # The Accept-Language header parsed into an ordered list of language tags,
    # highest q-value first (ties keep header order), dropping "*" and empties.
    def preferred_languages
      weighted = accept_language_header.split(",").filter_map.with_index do |part, index|
        tag, *params = part.strip.split(";")
        tag = tag.to_s.strip
        next if tag.empty? || tag == "*"

        quality = 1.0
        params.each do |param|
          key, value = param.split("=", 2)
          quality = value.to_f if key.to_s.strip == "q"
        end
        [tag, quality, index]
      end

      weighted.sort_by { |_tag, quality, index| [-quality, index] }.map(&:first)
    end
  end
end
