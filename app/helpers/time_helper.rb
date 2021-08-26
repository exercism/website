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
    case parts[1]
    when "month", "months"
      unit = "mo"
    else
      unit = parts[1][0]
    end

    "#{parts[0]}#{unit}"
  end
end
