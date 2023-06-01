module Premium
  MONTH_AMOUNT_IN_CENTS = 9_99
  MONTH_AMOUNT_IN_DOLLARS = MONTH_AMOUNT_IN_CENTS / 100.0
  YEAR_AMOUNT_IN_CENTS = 99_99
  YEAR_AMOUNT_IN_DOLLARS = YEAR_AMOUNT_IN_CENTS / 100.0
  LIFETIME_AMOUNT_IN_CENTS = 49_900
  LIFETIME_AMOUNT_IN_DOLLARS = LIFETIME_AMOUNT_IN_CENTS / 100.0

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

  def self.amount_in_dollars_from_interval(interval)
    case interval
    when :month
      Premium::MONTH_AMOUNT_IN_DOLLARS
    when :year
      Premium::YEAR_AMOUNT_IN_DOLLARS
    when :lifetime
      Premium::LIFETIME_AMOUNT_IN_DOLLARS
    end
  end
end
