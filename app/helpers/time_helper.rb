module TimeHelper
  def time_ago_in_words(time, short: false)
    t = super(time)
    return t unless short
    return "now" if t == "less than a minute"

    t.gsub!(/^about /, '')

    parts = t.split(' ')
    "#{parts[0]}#{parts[1][0]}"
  end
end
