class ViewComponents::Community::Stories::VideoLength < ViewComponents::ViewComponent
  initialize_with :video

  def to_s
    hours, minutes = video.length_in_minutes.divmod(60)

    parts = [
      hours.positive? ? format("%02d#{'HR'.pluralize(hours).upcase}", hours) : nil,
      minutes.positive? ? format("%02d#{'MIN'.pluralize(minutes).upcase}", minutes) : nil
    ].compact

    "LENGTH #{parts.join(' ')}"
  end
end
