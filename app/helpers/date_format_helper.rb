module DateFormatHelper
  # English dates keep Exercism's "28th Sep 2026" form. Other locales use rails-i18n's
  # long date format, because ordinals and month names only exist for English.
  def format_date(date)
    return I18n.l(date.to_date, format: :long) unless I18n.locale == :en

    date.strftime("#{date.day.ordinalize} %b %Y")
  end

  def format_datetime(datetime)
    return "#{I18n.l(datetime.to_date, format: :long)}, #{datetime.strftime('%H:%M')} UTC" unless I18n.locale == :en

    datetime.strftime("#{datetime.day.ordinalize} %b %Y, %H:%M UTC")
  end

  # "Sep 2014" in English. I18n.l takes the month abbreviation from the
  # current locale's rails-i18n data, which strftime cannot do.
  def format_month_year(date)
    I18n.l(date.to_date, format: '%b %Y')
  end
end
