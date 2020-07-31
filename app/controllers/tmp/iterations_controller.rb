class Tmp::IterationsController < ApplicationController
  def create
    user = User.create!(handle: SecureRandom.uuid)
    track = Track.find_by(slug: :csharp) ||
           Track.create!(slug: 'csharp', title: 'C#', repo_url: "http://github.com/exercism/csharp")
    exercise = ConceptExercise.find_by(track: track, slug: "two-fer") ||
               ConceptExercise.create!(track: track, uuid: SecureRandom.uuid, slug: "two-fer", prerequisites: [], title: "Two Fer")
    solution = ConceptSolution.create!(uuid: SecureRandom.uuid, user: user, exercise: exercise)

    git_exercise = track.repo.exercise('two-fer', track.repo.head_sha)
    example = git_exercise.read_file_blob("Example.cs")

    files = [
      {
        filename: "TwoFer.cs",
        content: example
      }
    ]

    Iteration::Create.(solution, files, submitted_via: "script")

    head 200
  end
end
