module TimeHelper
  def time_ago_in_words(time, short: false)
    t = super(time)
    t.gsub!(/^about /, '')

    unless short
      return "seconds" if t == "a few seconds"
      return "seconds" if t == "less than a minute"

      return t
    end

    return "1s" if t == "less than a minute"

    parts = t.split(' ')

    # If the time is more than 5 years ago, the value is literally "over 5 years" as opposed
    # to "3 years" or "2 months"
    is_over = parts[0] == "over"
    parts.shift if is_over

    case parts[1]
    when "month", "months"
      unit = "mo"
    else
      unit = parts[1][0]
    end

    "#{"over " if is_over}#{parts[0]}#{unit}"
  end
end
