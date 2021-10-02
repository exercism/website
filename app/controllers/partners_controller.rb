class PartnersController < ApplicationController
  def go_developer_network
    @track = Track.find('go')
    @num_concepts = @track.concepts.count
    @num_exercises = @track.exercises.count
  end
end
