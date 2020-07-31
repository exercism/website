class Tmp::IterationsController < ApplicationController
  def create

    track_slug = params[:track_slug].underscore.dasherize
    exercise_slug = params[:exercise_slug].underscore.dasherize
    exercise_title = params[:exercise_slug].titleize

    user = User.create!(handle: SecureRandom.uuid)
    track = Track.find_by(slug: track_slug)
    exercise = ConceptExercise.find_by(track: track, slug: exercise_slug) ||
               ConceptExercise.create!(track: track, uuid: SecureRandom.uuid, slug: exercise_slug, prerequisites: [], title: exercise_title)
    solution = ConceptSolution.create!(uuid: SecureRandom.uuid, user: user, exercise: exercise)

    files = [
      {
        filename: params[:exercise_filename],
        content: params[:exercise_implementation]
      }
    ]

    Iteration::Create.(solution, files, submitted_via: "script")

    head 200
  end
end
