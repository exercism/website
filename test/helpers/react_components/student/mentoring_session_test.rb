require_relative "../react_component_test_case"

class ReactComponents::Student::MentoringSessionTest < ReactComponentTestCase
  test "mentoring solution renders with discussion" do
    mentor = create :user
    student = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user: student, track:)
    discussion = create(:mentor_discussion, solution:, mentor:)
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)

    iteration_1 = create(:iteration, solution:)
    iteration_2 = create(:iteration, solution:)
    create :mentor_discussion_post, discussion:, iteration: iteration_2, seen_by_student: true

    iteration_3 = create(:iteration, solution:)
    create :mentor_discussion_post, discussion:, iteration: iteration_3, seen_by_student: true
    create :mentor_discussion_post, discussion:, iteration: iteration_3, seen_by_student: false

    component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, discussion)
    component.stubs(current_user: student)

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
          flair: mentor&.flair,
          bio: mentor.bio,
          languages_spoken: mentor.languages_spoken,
          avatar_url: mentor.avatar_url,
          reputation: mentor.formatted_reputation,
          num_discussions: 0,
          pronouns: nil
        },
        track_objectives: "",
        out_of_date: false,
        videos: [],
        donation: {
          show_donation_modal: true,
          request: {
            endpoint: Exercism::Routes.current_api_payments_subscriptions_url,
            options: {
              initial_data: AssembleCurrentSubscription.(student)
            }
          }
        },
        links: {
          exercise: Exercism::Routes.track_exercise_mentor_discussions_url(track, exercise),
          create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid),
          learn_more_about_private_mentoring: Exercism::Routes.doc_path(:using, "feedback/private"),
          private_mentoring: solution.external_mentoring_request_url,
          mentoring_guide: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
          donations_settings: Exercism::Routes.donations_settings_url,
          donate: Exercism::Routes.donate_url
        }

      }
  end

  test "mentoring solution renders with request" do
    student = create :user
    track = create :track
    exercise = create(:concept_exercise, track:)
    solution = create(:concept_solution, user: student, track:)
    mentor_request = create :mentor_request,
      solution:,
      comment_markdown: "Hello",
      updated_at: Time.utc(2016, 12, 25)

    iteration = create(:iteration, solution:)

    component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, nil)
    component.stubs(current_user: student)

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
        donation: {
          show_donation_modal: true,
          request: {
            endpoint: Exercism::Routes.current_api_payments_subscriptions_url,
            options: {
              initial_data: AssembleCurrentSubscription.(student)
            }
          }
        },
        links: {
          exercise: Exercism::Routes.track_exercise_mentor_discussions_url(track, exercise),
          create_mentor_request: Exercism::Routes.api_solution_mentor_requests_path(solution.uuid),
          learn_more_about_private_mentoring: Exercism::Routes.doc_path(:using, "feedback/private"),
          private_mentoring: solution.external_mentoring_request_url,
          mentoring_guide: Exercism::Routes.doc_path(:using, "feedback/guide-to-being-mentored"),
          donations_settings: Exercism::Routes.donations_settings_url,
          donate: Exercism::Routes.donate_url
        }
      }
  end

  test "doesn't shows modal to insiders" do
    student = create :user
    solution = create :concept_solution, user: student
    create(:iteration, solution:)
    mentor_request = create(:mentor_request, solution:)

    generate_data = proc do
      component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, nil)
      component.stubs(current_user: student)
      component.to_h
    end

    # Not an insider shows model
    assert generate_data.().dig(:donation, :show_donation_modal)

    # Being an insider doesn't
    student.update!(insiders_status: :active)
    refute generate_data.().dig(:donation, :show_donation_modal)
  end

  test "doesn't shows modal to recent donors" do
    student = create :user
    solution = create :concept_solution, user: student
    create(:iteration, solution:)
    mentor_request = create(:mentor_request, solution:)

    generate_data = proc do
      component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, nil)
      component.stubs(current_user: student)
      component.to_h
    end

    # No recent donations shows modal
    student.expects(donated_in_last_35_days?: false)
    assert generate_data.().dig(:donation, :show_donation_modal)

    # Recent donations block it
    create :payments_payment, user: student, created_at: Time.current - 34.days
    student.expects(donated_in_last_35_days?: true)
    refute generate_data.().dig(:donation, :show_donation_modal)
  end

  test "sets show_donation_modal correctly" do
    student = create :user
    solution = create :concept_solution, user: student
    create(:iteration, solution:)
    mentor_request = create(:mentor_request, solution:)

    generate_data = proc do
      component = ReactComponents::Student::MentoringSession.new(solution, mentor_request, nil)
      component.stubs(current_user: student)
      component.to_h
    end

    # No testimonials shows model
    assert generate_data.().dig(:donation, :show_donation_modal)

    # 1/2 testimonials doesn't
    2.times do
      create(:mentor_testimonial, student:)
      refute generate_data.().dig(:donation, :show_donation_modal)
    end

    # 3 testimonials does
    create(:mentor_testimonial, student:)
    assert generate_data.().dig(:donation, :show_donation_modal)

    # 4/5 testimonials don't
    2.times do
      create(:mentor_testimonial, student:)
      refute generate_data.().dig(:donation, :show_donation_modal)
    end

    # 6 testimonials does
    create(:mentor_testimonial, student:)
    assert generate_data.().dig(:donation, :show_donation_modal)
  end
end
