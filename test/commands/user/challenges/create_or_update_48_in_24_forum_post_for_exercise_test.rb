require "test_helper"

class User::Challenges::CreateOrUpdate48In24ForumPostForExerciseTest < ActiveSupport::TestCase
  test "creates new forum post when not already created" do
    exercise = create :practice_exercise, slug: 'leap'
    date = Time.utc(2024, 1, 16)

    stub_request(:get, "https://forum.exercism.org/c/364/show").
      to_return(
        status: 200,
        body: { category: { id: 364, slug: "48in24" } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://forum.exercism.org/c/48in24/364.json").
      to_return(
        status: 200,
        body: {
          topic_list: {
            topics: []
          }
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, "https://forum.exercism.org/posts").
      with(
        body: {
          category: "364",
          raw: "_This issue is a discussion for contributors to collaborate in getting ready to be featured in #48in24. Please refer to [this forum topic](https://forum.exercism.org/t/48in24-exercise-forum-topics/8963) for more info._\n\n---\n\nWe will be featuring **Leap** from **Jan 16** onwards.\n\n### Staff jobs\n\nThese are things for Erik/Jeremy to do:\n- ☐ Check/update exercise in Problem Specifications\n- ☐ Create + schedule video\n\n### Community jobs\n\nFor each track:\n- Implement Leap\n- Add approaches (and an approaches introduction!) for each idiomatic or interesting/educational approach.\n- Add video walkthroughs (record yourself solving and digging deeper into the exercise).\n- Highlight up to 16 different featured exercises _(coming soon)_\n\n### Existing Approaches\n\nYou can use these as the basis for approaches on your own tracks. Feel free to copy/paste/reuse/rewrite/etc as you see fit! Maybe ask ChatGPT to translate to your programming language.\n\n\n\n### Track Statuses\n\nYou can see an overview of which tracks have implemented the exercise at the [#48in24 implementation status page](https://exercism.org/challenges/48in24/implementation_status).", # rubocop:disable Layout/LineLength
          title: "[48in24 Exercise] [01-16] Leap"
        }
      ).
      to_return(status: 200, body: "", headers: {})

    User::Challenges::CreateOrUpdate48In24ForumPostForExercise.(exercise.slug, date)
  end

  test "updates forum post when already created" do
    exercise = create :practice_exercise, slug: 'leap'
    date = Time.utc(2024, 1, 16)

    stub_request(:get, "https://forum.exercism.org/c/364/show").
      to_return(
        status: 200,
        body: { category: { id: 364, slug: "48in24" } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://forum.exercism.org/c/48in24/364.json").
      to_return(
        status: 200,
        body: {
          topic_list: {
            topics: [{ id: 8964, title: "[48in24 Exercise] [01-16] Leap", slug: "48in24-exercise-01-16-leap" }]
          }
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://forum.exercism.org/t/8964.json").
      to_return(
        status: 200,
        body:
          { post_stream: { posts: [{ id: 24_899 }] } }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, "https://forum.exercism.org/posts/24899.json").
      to_return(
        status: 200,
        body:
        { id: 24_899, raw: "static part\n### Existing Approaches\ndynamic part" }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:put, "https://forum.exercism.org/posts/24899").
      with(
        body: {
          post: {
            raw: "static part\n\n### Existing Approaches\n\nYou can use these as the basis for approaches on your own tracks. Feel free to copy/paste/reuse/rewrite/etc as you see fit! Maybe ask ChatGPT to translate to your programming language.\n\n\n\n### Track Statuses\n\nYou can see an overview of which tracks have implemented the exercise at the [#48in24 implementation status page](https://exercism.org/challenges/48in24/implementation_status)." # rubocop:disable Layout/LineLength
          }
        }
      ).
      to_return(status: 200, body: "", headers: {})

    User::Challenges::CreateOrUpdate48In24ForumPostForExercise.(exercise.slug, date)
  end
end
