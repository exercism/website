class Exercise
  class MentorNotes
    def initialize(exercise)
      @exercise = exercise
    end

    def to_s
      markdown = Git::WebsiteCopy.new.mentor_notes_for(track.slug, exercise.slug).strip
      Markdown::Parse.(markdown)
    end

    def edit_url
      "https://github.com/exercism/website-copy/edit/main/tracks/#{track.slug}/exercises/#{exercise.slug}/mentoring.md"
    end

    private
    attr_reader :exercise

    def track
      exercise.track
    end
  end
end
