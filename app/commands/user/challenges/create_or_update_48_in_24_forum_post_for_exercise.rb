class User::Challenges::CreateOrUpdate48In24ForumPostForExercise
  include Mandate

  initialize_with :slug, :date

  def call
    return if Rails.env.development?

    if topic.nil?
      create_topic!
    else
      update_topic!
    end
  end

  private
  def create_topic!
    client.create_topic({
      title: "%<prefix>s [%<month>02d-%<day>02d] %<title>s" % {
        prefix: PREFIX, month: date.month, day: date.day, title: exercise.title
      },
      raw: create_body,
      category: category["id"]
    })
  end

  def update_topic!
    client.edit_post(post["id"], update_body)
  end

  memoize
  def post
    topic_post = topic.dig("post_stream", "posts").first

    return nil if topic_post.nil?

    client.get_post(topic_post["id"])
  end

  memoize
  def topic
    category_topic = client.get("/c/#{category['slug']}/#{category['id']}.json").
      dig("response_body", "topic_list", "topics").
      find { |topic| topic["title"].starts_with?(PREFIX) && topic["title"].ends_with?(exercise.title) }

    return nil if category_topic.nil?

    client.topic(category_topic["id"])
  end

  memoize
  def category = client.category(CATEGORY_ID)

  memoize
  def client = Exercism.discourse_client

  def create_body = body(static_part, dynamic_part)

  def update_body
    post_static_part = post["raw"][0..post["raw"].index("### Existing Approaches") - 1].strip
    body(post_static_part, dynamic_part)
  end

  def body(static, dynamic)
    <<~MARKDOWN.strip
      #{static}

      #{dynamic}
    MARKDOWN
  end

  def static_part
    <<~MARKDOWN.strip
      #{header}

      #{staff_jobs}

      #{community_jobs}
    MARKDOWN
  end

  def dynamic_part
    <<~MARKDOWN.strip
      #{existing_approaches}

      #{track_statuses}
    MARKDOWN
  end

  def header
    <<~HEADER.strip
      _This issue is a discussion for contributors to collaborate in getting ready to be featured in #48in24. Please refer to [this forum topic](https://forum.exercism.org/t/48in24-exercise-forum-topics/8963) for more info._

      ---

      We will be featuring **#{exercise.title}** from **#{date.strftime('%b %d')}** onwards.#{' '}
    HEADER
  end

  def staff_jobs
    <<~STAFF_JOBS.strip
      ### Staff jobs

      These are things for Erik/Jeremy to do:
      - ☐ Check/update exercise in Problem Specifications
      - ☐ Create + schedule video
    STAFF_JOBS
  end

  def community_jobs
    <<~COMMUNITY_JOBS.strip
      ### Community jobs

      For each track:
      - Implement #{exercise.title}
      - Add approaches (and an approaches introduction!) for each idiomatic or interesting/educational approach.
      - Add video walkthroughs (record yourself solving and digging deeper into the exercise).
      - Highlight up to 16 different featured exercises _(coming soon)_
    COMMUNITY_JOBS
  end

  def existing_approaches
    markdown = <<~MARKDOWN
      ### Existing Approaches

      You can use these as the basis for approaches on your own tracks. Feel free to copy/paste/reuse/rewrite/etc as you see fit! Maybe ask ChatGPT to translate to your programming language.

    MARKDOWN

    implementations.flat_map { |exercise| exercise.approaches.map { |approach| [approach.slug, exercise.slug, exercise.track.slug] } }.
      group_by(&:first).
      transform_values { |v| v.map { |x| x[1..] } }.
      sort_by { |k, _v| k }.
      each do |approach, exercises|
        exercises_md = exercises.sort_by(&:second).map do |(exercise, track)|
          "[#{track}](https://exercism.org#{Exercism::Routes.track_exercise_approach_path(track, exercise, approach)})"
        end.join(', ')
        markdown += "- `#{approach}` (#{exercises_md})\n"
      end

    markdown
  end

  def track_statuses
    <<~MARKDOWN
      ### Track Statuses

      You can see an overview of which tracks have implemented the exercise at the [#48in24 implementation status page](https://exercism.org#{Exercism::Routes.implementation_status_challenge_path('48in24')}).
    MARKDOWN
  end

  memoize
  def exercise = PracticeExercise.find_by!(slug:)

  memoize
  def implementations
    PracticeExercise.available.includes(:track, :approaches, :community_videos).
      joins(:track).
      where(tracks: { active: true }).
      where(slug: exercise.slug)
  end

  CATEGORY_ID = 364
  PREFIX = '[48in24 Exercise]'.freeze
  private_constant :CATEGORY_ID, :PREFIX
end
