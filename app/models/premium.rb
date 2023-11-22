module Premium
  MINIMUM_AMOUNT_FOR_INSIDERS_IN_CENTS = 9_99

  MONTH_AMOUNT_IN_CENTS = 9_99
  YEAR_AMOUNT_IN_CENTS = 99_00
  LIFETIME_AMOUNT_IN_CENTS = 499_00

  MONTH_AMOUNT_IN_DOLLARS = MONTH_AMOUNT_IN_CENTS / 100.0
  YEAR_AMOUNT_IN_DOLLARS = YEAR_AMOUNT_IN_CENTS / 100.0
  LIFETIME_AMOUNT_IN_DOLLARS = LIFETIME_AMOUNT_IN_CENTS / 100.0

  def self.amount_in_cents_from_interval(interval)
    case interval.to_sym
    when :month
      MONTH_AMOUNT_IN_CENTS
    when :monthly
      MONTH_AMOUNT_IN_CENTS
    when :year
      YEAR_AMOUNT_IN_CENTS
    when :yearly
      YEAR_AMOUNT_IN_CENTS
    when :lifetime
      LIFETIME_AMOUNT_IN_CENTS
    end
  end

  def self.amount_in_dollars_from_interval(interval)
    case interval.to_sym
    when :month
      MONTH_AMOUNT_IN_DOLLARS
    when :monthly
      MONTH_AMOUNT_IN_DOLLARS
    when :year
      YEAR_AMOUNT_IN_DOLLARS
    when :yearly
      YEAR_AMOUNT_IN_DOLLARS
    when :lifetime
      LIFETIME_AMOUNT_IN_DOLLARS
    end
  end
end
