class Tmp::IterationsController < ApplicationController
  def create
    user = User.create!(handle: SecureRandom.uuid)
    ruby = Track.find_by(slug: :ruby) ||
           Track.create!(slug: 'ruby', title: 'Ruby', repo_url: "http://github.com/exercism/ruby")
    exercise = ConceptExercise.find_by(track: ruby, slug: "two-fer") ||
               ConceptExercise.create!(track: ruby, uuid: SecureRandom.uuid, slug: "two-fer", prerequisites: [], title: "Two Fer")
    solution = ConceptSolution.create!(uuid: SecureRandom.uuid, user: user, exercise: exercise)

    files = [
      {
        filename: "two_fer.rb",
        content: %{
  class TwoFer
    def self.two_fer(name=nil)
      "One for \#{name}, one for me"
    end
  end
  # #{SecureRandom.hex}
        }.strip
      }
    ]

    Iteration::Create.(solution, files, submitted_via: "script")

    head 200
  end
end
