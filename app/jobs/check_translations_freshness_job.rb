class CheckTranslationsFreshnessJob < ApplicationJob
  queue_as :cron

  def perform
    TranslationRepo::CheckFreshness.()
  end
end
