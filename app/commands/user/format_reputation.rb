class User::FormatReputation
  include Mandate
  include ActionView::Helpers::NumberHelper

  initialize_with :rep

  def call
    return number_with_delimiter(rep) if rep < 10_000
    return "#{((rep * 10) / BigDecimal(1000)).floor / 10.0}k" if rep < 100_000

    "#{(rep / BigDecimal(1000)).floor}k"
  end
end
