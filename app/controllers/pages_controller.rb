class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    return redirect_to dashboard_path if user_signed_in?

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
          blurb: "Which of the residents drinks water? Who owns the zebra? Can you solve the Zebra Puzzle with code?"),
        num_tracks: 70
      }
    ]
  end

  def health_check
    user = User.find(User::SYSTEM_USER_ID)

    render json: {
      ruok: true,
      sanity_data: {
        user: user.handle
      }
    }
  end

  def supporter_gobridge
    @blog_posts = BlogPost.where(slug: 'exercism-is-the-official-go-mentoring-platform')
  end
end
