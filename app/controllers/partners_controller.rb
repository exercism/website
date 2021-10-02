class PartnersController < ApplicationController
  def go_developer_network
    @track = Track.find('go')
    @num_concepts = @track.concepts.count
    @num_exercises = @track.exercises.count
    @num_tasks = @track.tasks.count
  end
end
