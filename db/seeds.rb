user = User.create!(handle: 'iHiD')
track = Track.create!(slug: 'ruby', title: 'Ruby', repo_url: "http://github.com/exercism/ruby")
UserTrack.create!(user: user, track: track)

concept_exercise = ConceptExercise.create!(track: track, uuid: SecureRandom.uuid, slug: "c1", prerequisites: [], title: "C1")
practice_exercise = PracticeExercise.create!(track: track, uuid: SecureRandom.uuid, slug: "p1", prerequisites: [], title: "P1")
concept_solution = ConceptSolution.create!(exercise: concept_exercise, user: user, uuid: SecureRandom.uuid)
practice_solution = PracticeSolution.create!(exercise: practice_exercise, user: user, uuid: SecureRandom.uuid)

Iteration.create!(
  solution: concept_solution,
  uuid: SecureRandom.uuid,
  submitted_via: "cli"
)

track = Track.create!(slug: 'csharp', title: 'C#', repo_url: "http://github.com/exercism/csharp")
UserTrack.create!(user: user, track: track)