module TimeHelper
  def time_ago_in_words(time, short: false)
    t = "#{super(time)}" # rubocop:disable Style/RedundantInterpolation Required to unfreeze string
    t.gsub!(/^about /, '')
    t.gsub!(/^almost /, '')

    unless short
      return "seconds" if t == "a few seconds"
      return "seconds" if t == "less than a minute"

      return t
    end

    return "1s" if t == "less than a minute"

    # The abbreviations below are built by parsing the English phrasing (e.g. "2 months"),
    # so other locales get their full translated phrase (e.g. "約2年" in Japanese).
    return t unless I18n.locale == :en

    parts = t.split(' ')

    # If the time is more than 5 years ago, the value is literally "over 5 years" as opposed
    # to "3 years" or "2 months"
    if parts[0] == "over"
      prefix = "over " unless short
      suffix = "+" if short
      parts.shift
    end

    case parts[1]
    when "month", "months"
      unit = "mo"
    else
      unit = parts[1][0]
    end

    "#{prefix}#{parts[0]}#{unit}#{suffix}"
  end
end
