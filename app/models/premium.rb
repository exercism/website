module Premium
  MONTH_AMOUNT_IN_CENTS = 9_99
  YEAR_AMOUNT_IN_CENTS = 99_99
  LIFETIME_AMOUNT_IN_CENTS = 49_900

  def self.amount_in_cents_from_interval(interval)
    case interval
    when :month
      Premium::MONTH_AMOUNT_IN_CENTS
    when :year
      Premium::YEAR_AMOUNT_IN_CENTS
    when :lifetime
      Premium::LIFETIME_AMOUNT_IN_CENTS
    end
  end
end
