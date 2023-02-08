module DateFormatHelper
  def format_date(date)
    date.strftime("#{date.day.ordinalize} %b %Y")
  end

  def format_datetime(datetime)
    datetime.strftime("#{datetime.day.ordinalize} %b %Y, %H:%M UTC")
  end
end
