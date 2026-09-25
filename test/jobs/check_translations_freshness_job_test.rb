require "test_helper"

class CheckTranslationsFreshnessJobTest < ActiveJob::TestCase
  test "checks the translations are fresh" do
    TranslationRepo::CheckFreshness.expects(:call)

    CheckTranslationsFreshnessJob.perform_now
  end
end
