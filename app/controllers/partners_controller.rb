class PartnersController < ApplicationController
  skip_before_action :authenticate_user!

  def gobridge
    @track = Track.find('go')
    @num_concepts = @track.concepts.count
    @num_exercises = @track.exercises.count
    @num_tasks = @track.tasks.count
  end
end
