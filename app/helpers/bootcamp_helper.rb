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
end
