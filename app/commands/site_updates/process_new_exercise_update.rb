module SiteUpdates
  class ProcessNewExerciseUpdate
    include Mandate

    initialize_with :exercise

    def call
      if exercise.wip?
        destroy!
      else
        begin
          create!
        rescue ActiveRecord::RecordNotUnique
          update!
        end
      end
    end

    def destroy!
      SiteUpdates::NewExerciseUpdate.where(
        exercise: exercise,
        track: exercise.track
      ).destroy_all
    end

    def create!
      SiteUpdates::NewExerciseUpdate.create!(
        exercise: exercise,
        track: exercise.track
      )
    end

    def update!
      SiteUpdates::NewExerciseUpdate.find_by!(
        exercise: exercise,
        track: exercise.track
      ).regenerate_rendering_data!
    end
  end
end
