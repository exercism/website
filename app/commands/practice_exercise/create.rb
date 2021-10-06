class PracticeExercise
  class Create
    include Mandate

    initialize_with :uuid, :track, :attributes

    def call
      PracticeExercise.create!(
        uuid: uuid,
        track: track,
        **attributes
      ).tap do |exercise|
        SiteUpdates::ProcessNewExerciseUpdate.(exercise)
      end
    rescue ActiveRecord::RecordNotUnique
      PracticeExercise.find_by!(uuid: uuid, track: track)
    end
  end
end
