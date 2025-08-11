class LocalizationTranslationChannel < ApplicationCable::Channel
  def self.broadcast!(translation)
    ActionCable.server.broadcast(
      channel_name(translation.locale),
      {
        key: translation.key,
        locale: translation.locale,
        value: translation.value
      }
    )
  end

  def subscribed
    stream_from self.class.channel_name(params[:locale])
  end

  def unsubscribed; end

  def self.channel_name(locale)
    "localization_translations_#{locale}"
  end
end
