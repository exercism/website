module ReactComponents
  module Mentoring
    class Session < ReactComponent
      def initialize(request: nil, discussion: nil)
        raise "Either request or discussion must be provided" unless request || discussion

        @request = request.presence || discussion.request
        @discussion = discussion || request.discussion
        @solution = @request.solution

        super()
      end

      def to_s
        super(
          "mentoring-session",
          {
            user_handle: current_user.handle,
            request: SerializeMentorSessionRequest.(request, current_user),
            discussion: discussion ? SerializeMentorDiscussionForMentor.(discussion, relationship: mentor_student_relationship) : nil,
            track: SerializeMentorSessionTrack.(track),
            exercise: SerializeMentorSessionExercise.(exercise),
            iterations:,
            instructions: Markdown::Parse.(solution.instructions),
            test_files: SerializeFiles.(solution.test_files),
            student: SerializeStudent.(
              student,
              current_user,
              user_track: UserTrack.for(student, track),
              relationship: mentor_student_relationship,
              anonymous_mode: discussion&.anonymous_mode?,
              discussion:
            ),
            student_solution_uuid: solution.uuid,
            mentor_solution:,
            exemplar_files: SerializeExemplarFiles.(exercise.exemplar_files),
            guidance: {
              exercise: exercise.mentoring_notes_content,
              track: track.mentoring_notes_content,
              links: {
                improve_exercise_guidance: exercise.mentoring_notes_edit_url,
                improve_track_guidance: track.mentoring_notes_edit_url
              }
            },
            out_of_date: solution.out_of_date?,
            download_command: solution.mentor_download_cmd,
            scratchpad: {
              is_introducer_hidden: current_user&.introducer_dismissed?("scratchpad"),
              links: {
                markdown: Exercism::Routes.doc_url(:mentoring, "markdown"),
                hide_introducer: Exercism::Routes.hide_api_settings_introducer_path("scratchpad"),
                self: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
              }
            },
            links:
          }
        )
      end

      private
      attr_reader :solution, :request, :discussion

      memoize
      def mentor_student_relationship
        Mentor::StudentRelationship.find_by(mentor: current_user, student:)
      end

      def links
        {
          mentor_dashboard: Exercism::Routes.mentoring_inbox_path,
          mentor_queue: Exercism::Routes.mentoring_queue_path,
          exercise: Exercism::Routes.track_exercise_path(track, exercise),
          mentoring_docs: Exercism::Routes.docs_section_path(:mentoring)
        }
      end

      def iterations
        if discussion
          comment_counts = discussion.posts.
            group(:iteration_id, :seen_by_mentor).
            count
        else
          comment_counts = {}
        end

        SerializeIterations.(solution.iterations, comment_counts:)
      end

      def mentor_solution
        ms = ::Solution.for(current_user, exercise)
        ms ? SerializeCommunitySolution.(ms) : nil
      end

      memoize
      delegate :exercise, :track, to: :solution

      def student
        solution.user
      end

      memoize
      def scratchpad
        ScratchpadPage.new(about: exercise)
      end

      class SerializeExemplarFiles
        include Mandate

        initialize_with :files

        def call
          files.map do |filename, content|
            {
              filename: filename.gsub(%r{^\.meta/}, ''),
              content:
            }
          end
        end
      end
    end
  end
end
