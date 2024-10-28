module BootcampHelper
  def flag_for_country_code(country_code)
    country_code.upcase.split("").
      map { |char| (127_397 + char.ord).chr("UTF-8") }.
      join
  end
end
