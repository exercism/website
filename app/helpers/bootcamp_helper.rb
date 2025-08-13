module BootcampHelper
  def flag_for_country_code(country_code)
    country_code.upcase.split("").
      map { |char| (127_397 + char.ord).chr("UTF-8") }.
      join
  end

  def flag_for_locale(locale)
    country = locale.to_s.split("-").last
    case country
    when "en"
      country = "us"
    end
    flag_for_country_code(country)
  end

  def name_for_locale(locale)
    case locale.to_s
    when "en"
      "English"
    when "hu"
      "Hungarian"
    else
      I18n.t("locales.#{locale}", default: locale.to_s.upcase)
    end
  end
end
