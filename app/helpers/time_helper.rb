module TimeHelper
  def time_ago_in_words(time, short: false)
    t = super(time)
    return t unless short

    parts = t.split(' ')
    "#{parts[0]}#{parts[1][0]} #{parts[2]}"
  end
end
