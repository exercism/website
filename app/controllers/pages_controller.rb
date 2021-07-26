class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    # TODO: (required) Remove the nonsense
    @tracks = (Track.active.order(num_students: :desc).limit(12).to_a * 10)[0, 12]
    @num_tracks = Track.active.count

    @showcase_exercises = [
      {
        exercise: Exercise.new(icon_name: "bob", title: "Bob",
                               blurb: "Bob is a lackadaisical teenager. In conversation, his responses are very limited."),
        num_tracks: 40
      },
      {
        exercise: Exercise.new(icon_name: "queen-attack", title: "Queen Attack",
                               blurb: "Given the position of two queens on a chess board, indicate whether or not they are positioned so that they can attack each other"), # rubocop:disable Layout/LineLength
        num_tracks: 60
      },
      {
        exercise: Exercise.new(icon_name: "hamming", title: "Hamming",
                               blurb: "Calculate the Hamming difference between two DNA strands."),
        num_tracks: 70
      }
    ]
  end

  def self.readme_url
    "https://raw.githubusercontent.com/exercism/v3-beta/main/README.md?q=#{Time.current.min}"
  end

  def beta
    # solution = Solution.first
    resp = RestClient.get(self.class.readme_url)

    @content = Markdown::Parse.(resp.body)
  end

  def health_check
    render json: { ruok: true }
  end
end
