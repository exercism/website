require_relative "../../react_component_test_case"

class ReactComponents::Mentoring::Representations::RepresentationTest < ReactComponentTestCase
  test "representation rendered correctly" do
    skip # TODO: fix

    mentor = create :user
    representation = create :exercise_representation
    submission_1 = create :submission
    create :iteration, submission: submission_1
    submission_1_file = create :submission_file, submission: submission_1, filename: "impl.rb", content: "Impl // Foo"
    create :submission_representation, submission: submission_1, ast_digest: representation.ast_digest
    submission_2 = create :submission
    create :iteration, submission: submission_2
    submission_2_file = create :submission_file, submission: submission_2, filename: "impl.rb", content: "Impl // Bar"
    create :submission_representation, submission: submission_2, ast_digest: representation.ast_digest
    examples = [submission_1, submission_2]

    component = ReactComponents::Mentoring::Representations::Representation.new(mentor, representation, examples)

    assert_component component,
      "mentoring-representation",
      {
        representation: {
          id: representation.id,
          exercise: {
            icon_url: representation.exercise.icon_url,
            title: representation.exercise.title
          },
          track: {
            icon_url: representation.track.icon_url,
            title: representation.track.title
          },
          num_submissions: representation.num_submissions,
          appears_frequently: representation.appears_frequently?,
          feedback_markdown: representation.feedback_markdown,
          last_submitted_at: representation.last_submitted_at,
          links: {
            edit: Exercism::Routes.edit_mentoring_automation_path(representation)
          }
        },
        examples: [
          {
            filename: submission_1_file.filename,
            type: :solution,
            digest: submission_1_file.digest,
            content: submission_1_file.content
          },
          {
            filename: submission_2_file.filename,
            type: :solution,
            digest: submission_2_file.digest,
            content: submission_2_file.content
          }
        ],
        mentor: {
          name: mentor.name,
          handle: mentor.handle,
          avatar_url: mentor.avatar_url
        }
      }
  end
end
