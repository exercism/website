class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @tracks = Track.active.order(num_students: :desc).limit(12).to_a
    @num_tracks = Track.active.count

    @showcase_exercises = [
      {
        exercise: Exercise.new(icon_name: "allergies", title: "Allergies",
          blurb: "Given a person's allergy score, determine whether or not they're allergic to a given item, and their full list of allergies."), # rubocop:disable Layout/LineLength
        num_tracks: 40
      },
      {
        exercise: Exercise.new(icon_name: "queen-attack", title: "Queen Attack",
          blurb: "Given the position of two queens on a chess board, indicate whether or not they are positioned so that they can attack each other"), # rubocop:disable Layout/LineLength
        num_tracks: 60
      },
      {
        exercise: Exercise.new(icon_name: "zebra-puzzle", title: "Zebra Puzzle",
          blurb: "Which of the residents drinks water? Who owns the zebra? Can you solve the Zebra Puzzle with code?"), # rubocop:disable Layout/LineLength
        num_tracks: 70
      }
    ]
  end

  def health_check
    render json: { ruok: true }
  end
end
