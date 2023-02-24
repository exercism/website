require_relative "../react_component_test_case"

class ReactComponents::Student::MentoringSessionTest < ReactComponentTestCase
  test "mentoring solution renders with discussion" do
    mentor = create :user
    student = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, user: student, track: track
    discussion = create :mentor_discussion, solution: solution, mentor: mentor
    mentor_request = create :mentor_request,
      solution: solution,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)

    iteration_1 = create :iteration, solution: solution
    iteration_2 = create :iteration, solution: solution
    create :mentor_discussion_post, discussion: discussion, iteration: iteration_2, seen_by_student: true

    iteration_3 = create :iteration, solution: solution
    create :mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_student: true
    create :mentor_discussion_post, discussion: discussion, iteration: iteration_3, seen_by_student: false

    component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, discussion)
    component.stubs(current_user: student)
    component.stubs(user_signed_in?: true)

    assert_component component,
      "student-mentoring-session",
      {
        user_handle: student.handle,
        request: SerializeMentorSessionRequest.(mentor_request, student),
        discussion: SerializeMentorDiscussionForStudent.(discussion),
        track: SerializeMentorSessionTrack.(track),
        exercise: SerializeMentorSessionExercise.(exercise),
        iterations: [
          SerializeIteration.(iteration_1).merge(unread: false),
          SerializeIteration.(iteration_2).merge(unread: false),
          SerializeIteration.(iteration_3).merge(unread: true)
        ],
        mentor: {
          name: mentor.name,
          handle: mentor.handle,
          bio: mentor.bio,
          languages_spoken: mentor.languages_spoken,
          avatar_url: mentor.avatar_url,
          reputation: mentor.formatted_reputation,
          num_discussions: 0
        },
        track_objectives: "",
        out_of_date: false,
        videos: [],
        links: {
          exercise: Exercism::Routes.track_exercise_mentor_discussions_url(track, exercise),
          create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid),
          learn_more_about_private_mentoring: Exercism::Routes.doc_path(:using, "feedback/private"),
          private_mentoring: solution.external_mentoring_request_url,
          mentoring_guide: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
          donation_links: {
            show_donation_modal: true,
            request: {
              endpoint: Exercism::Routes.api_donations_active_subscription_url,
              options: {
                initial_data: AssembleActiveSubscription.(student)
              }
            },
            user_signed_in: true,
            captcha_required: student.captcha_required?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
            links: {
              settings: Exercism::Routes.donations_settings_url,
              donate: Exercism::Routes.donate_url
            }
          }
        }
      }
  end

  test "mentoring solution renders with request" do
    student = create :user
    track = create :track
    exercise = create :concept_exercise, track: track
    solution = create :concept_solution, user: student, track: track
    mentor_request = create :mentor_request,
      solution: solution,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)

    iteration = create :iteration, solution: solution

    component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, nil)
    component.stubs(current_user: student)
    component.stubs(user_signed_in?: true)

    assert_component component,
      "student-mentoring-session",
      {
        user_handle: student.handle,
        request: SerializeMentorSessionRequest.(mentor_request, student),
        discussion: nil,
        track: SerializeMentorSessionTrack.(track),
        exercise: SerializeMentorSessionExercise.(exercise),
        iterations: [
          SerializeIteration.(iteration).merge(unread: false)
        ],
        mentor: nil,
        track_objectives: "",
        out_of_date: false,
        videos: [
          {
            url: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
            thumb: "https://exercism-static.s3.eu-west-1.amazonaws.com/blog/tutorial-making-the-most-of-being-mentored.png",
            title: "Making the most of being mentored",
            date: Date.new(2021, 9, 1).iso8601
          }
        ],
        links: {
          exercise: Exercism::Routes.track_exercise_mentor_discussions_url(track, exercise),
          create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid),
          learn_more_about_private_mentoring: Exercism::Routes.doc_path(:using, "feedback/private"),
          private_mentoring: solution.external_mentoring_request_url,
          mentoring_guide: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
          donation_links: {
            show_donation_modal: true,
            request: {
              endpoint: Exercism::Routes.api_donations_active_subscription_url,
              options: {
                initial_data: AssembleActiveSubscription.(student)
              }
            },
            user_signed_in: true,
            captcha_required: student.captcha_required?,
            recaptcha_site_key: ENV.fetch('RECAPTCHA_SITE_KEY', Exercism.secrets.recaptcha_site_key),
            links: {
              settings: Exercism::Routes.donations_settings_url,
              donate: Exercism::Routes.donate_url
            }
          }
        }
      }
  end

  test "sets show_donation_modal correctly" do
    student = create :user
    solution = create :concept_solution, user: student
    create :iteration, solution: solution
    mentor_request = create :mentor_request, solution: solution

    generate_data = proc do
      component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, nil)
      component.stubs(current_user: student)
      component.stubs(user_signed_in?: true)
      component.to_h
    end

    # No testimonials shows model
    assert generate_data.().dig(:links, :donation_links, :show_donation_modal)

    # 1/2/3 testimonials doesn't
    3.times do
      create :mentor_testimonial, student: student
      refute generate_data.().dig(:links, :donation_links, :show_donation_modal)
    end

    # 4 testimonials does
    create :mentor_testimonial, student: student
    assert generate_data.().dig(:links, :donation_links, :show_donation_modal)

    # 5/6/7/8 testimonials doesn't
    4.times do
      create :mentor_testimonial, student: student
      refute generate_data.().dig(:links, :donation_links, :show_donation_modal)
    end

    # 9 testimonials does
    create :mentor_testimonial, student: student
    assert generate_data.().dig(:links, :donation_links, :show_donation_modal)
  end
end
