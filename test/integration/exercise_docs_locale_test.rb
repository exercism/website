require "test_helper"

class ExerciseDocsLocaleTest < ActionDispatch::IntegrationTest
  # bob, before its instructions were updated and the appends added
  OLD_SHA = "7a42b345ebfa4e74899174abb4ed6b9301cf93b9".freeze
  LATEST_DOCS = %w[instructions.md instructions.append.md introduction.md introduction.append.md hints.md].freeze

  setup do
    @exercise = create :practice_exercise, slug: "bob"
    @track = @exercise.track
    @repo = Git::Repository.new(repo_url: @track.repo_url)
    @user = create :user, :staff
    @user.update!(locale: "hu")
    create(:user_track, user: @user, track: @track)
    @solution = create :practice_solution,
      exercise: @exercise, user: @user, git_sha: OLD_SHA, git_important_files_hash: SecureRandom.hex
    sign_in!(@user)
  end

  test "the banner is shown to a user whose docs are for a newer version" do
    with_served_locales(:hu) do
      with_published_translations({}) do
        publish_latest!

        get track_exercise_url(@track, @exercise)

        assert_select "html[lang=hu]"
        assert notice_data["docs_for_newer_version"]
        assert_equal track_exercise_url(@track, @exercise, exercise_locale: "en"), notice_data["links"]["english"]
        assert_includes response.body, "új instructions.md"
      end
    end
  end

  test "exercise_locale=en renders the pinned english docs with no banner" do
    with_served_locales(:hu) do
      with_published_translations({}) do
        publish_latest!

        get track_exercise_url(@track, @exercise, exercise_locale: "en")

        assert_select "html[lang=hu]"
        refute notice_data["docs_for_newer_version"]
        refute_includes response.body, "új instructions.md"
        assert_includes response.body, pinned_english_instructions
      end
    end
  end

  test "any other value is ignored" do
    with_served_locales(:hu) do
      with_published_translations({}) do
        publish_latest!

        get track_exercise_url(@track, @exercise, exercise_locale: "hu")

        assert notice_data["docs_for_newer_version"]
        assert_includes response.body, "új instructions.md"
      end
    end
  end

  test "the param has no effect on an up to date solution" do
    @solution.update!(git_sha: @exercise.git_sha)

    with_served_locales(:hu) do
      with_published_translations({}) do
        publish_latest!

        get track_exercise_url(@track, @exercise)
        assert_includes response.body, "új instructions.md"

        get track_exercise_url(@track, @exercise, exercise_locale: "en")
        assert_includes response.body, "új instructions.md"
      end
    end
  end

  test "the param has no effect in english" do
    get track_exercise_url(@track, @exercise)
    assert_select "html[lang='en-US']"
    assert_includes response.body, pinned_english_instructions

    get track_exercise_url(@track, @exercise, exercise_locale: "en")
    assert_select "html[lang='en-US']"
    assert_includes response.body, pinned_english_instructions
  end

  private
  def publish_latest!
    commit = @repo.lookup_commit(@exercise.git_sha)
    LATEST_DOCS.each do |file|
      publish_translated_content!(:hu, @repo, commit, "exercises/practice/bob/.docs/#{file}", "új #{file}")
    end
  end

  def pinned_english_instructions
    I18n.with_locale(:en) { Exercise::CachedContent::Generate.(@exercise, @solution)[:instructions] }
  end

  def notice_data
    node = Nokogiri::HTML(response.body).at_css("[data-react-id='student-update-exercise-notice']")
    JSON.parse(node["data-react-data"])
  end
end
