class Test::Components::TrackListsController < ApplicationController
  def show
    @tracks = [
      {
        "id" => 2,
        "trackTitle" => "Ruby",
        "trackIconUrl" => "https://assets.exercism.io/tracks/ruby-hex-white.png",
        "exerciseCount" => 20,
        "conceptExerciseCount" => 10,
        "practiceExerciseCount" => 10,
        "studentCount" => 10,
        "isNew" => true,
        "isJoined" => true,
        "tags" => ["OOP", "Web Dev"],
        "completedExerciseCount" => 15,
        "trackProgressPercentage" => "66.67",
        "url" => "https://exercism.io/tracks/1"
      }
    ]
  end
end
