module TimeHelper
  def time_ago_in_words(time, short: false)
    t = super(time)
    t.gsub!(/^about /, '')

    unless short
      return "seconds" if t == "a few seconds"
      return "seconds" if t == "less than a minute"

      return t
    end

    return "now" if t == "less than a minute"

    parts = t.split(' ')
    "#{parts[0]}#{parts[1][0]}"
  end
end
