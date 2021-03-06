require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateExercises < TableMigration
      include Mandate

      def table_name
        "exercises"
      end

      def model
        Exercise
      end

      def call
        remove_column :dark_icon_url
        remove_column :turquoise_icon_url
        remove_column :white_icon_url

        # These are redundant
        remove_column :core
        remove_column :auto_approve
        remove_column :length
        remove_column :unlocked_by_id
        remove_column :description
        remove_column :active

        add_column :status, :tinyint, null: false, default: 2
        add_non_nullable_column :icon_name, :string, 'slug'
        add_non_nullable_column :type, :string, "'PracticeExercise'"

        # We need these set for things like the important files hash
        # and setting the correct values for the solutions
        # We need to get the old broken JS exercises to give some special
        # treatment to.
        cleanup_exercises!

        legacy_exercises = Track.find_by_slug('javascript').exercises.where('slug like "legacy-%"')
        add_non_nullable_column :git_sha, :string do |exercise|
          exercise.update!(git_sha: exercise.git.head_sha)
        rescue
          raise unless legacy_exercises.include?(exercise)
          exercise.update!(git_sha: "6a8a5a41b89a45008b46ca18ff7ea800baca1c4c")
        end

        add_non_nullable_column :synced_to_git_sha, :string do |exercise|
          exercise.update!(synced_to_git_sha: exercise.git.head_sha)
        rescue
          raise unless legacy_exercises.include?(exercise)
          exercise.update!(synced_to_git_sha: "6a8a5a41b89a45008b46ca18ff7ea800baca1c4c")
        end

        add_non_nullable_column :git_important_files_hash, :string do |exercise|
          exercise.update!(git_important_files_hash: Git::GenerateHashForImportantExerciseFiles.(exercise))
        rescue
          p exercise.id
          p exercise.track.slug
          raise unless legacy_exercises.include?(exercise) ||
            ['research_experiment_1', 'javascript-legacy'].include?(exercise.track.slug)
          exercise.update!(git_important_files_hash: "")
        end

        # Finally update the legacy exercises, then we're done with them.
        legacy_exercises.update_all(status: :deprecated)

        add_index %i[track_id uuid], unique: true
      end

      def cleanup_exercises!
        Exercise.where(slug: "bracket-push").update_all(slug: 'matching-brackets')

        cleanup_exercise(3042, 602)
        cleanup_exercise(3658, 3656)
      end

      def cleanup_exercise(bad_id, good_id)
        bad_exercise = Exercise.find(bad_id)
        bad_exercise.solutions.find_each do |s|
          s.update(exercise_id: good_id)
        rescue ActiveRecord::RecordNotUnique
          s.delete
        end
        Exercise.where(id: bad_exercise.id).delete_all
      end
    end
  end
end
