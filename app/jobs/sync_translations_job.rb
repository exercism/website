class SyncTranslationsJob < ApplicationJob
  queue_as :dribble

  def perform
    TranslationRepo::Sync.()
  end
end
