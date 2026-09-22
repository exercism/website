class ViewComponents::Community::Stories::VideoLength < ViewComponents::ViewComponent
  initialize_with :video

  def to_s
    hours, minutes = video.length_in_minutes.divmod(60)

    parts = [
      hours.positive? ? format("%02d#{I18n.t("components.community.stories.video_length.hours", count: hours)}", hours) : nil,
      minutes.positive? ? format("%02d#{I18n.t("components.community.stories.video_length.minutes", count: minutes)}", minutes) : nil
    ].compact

    "#{I18n.t("components.community.stories.video_length.label")} #{parts.join(' ')}"
  end
end
