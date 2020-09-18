class Test::Components::Mentoring::MentorInboxesController < ApplicationController
  def show
    @sort_options = [
      { value: 'recent', text: 'Sort by Most Recent' },
      { value: 'exercise', text: 'Sort by Exercise' },
      { value: 'student', text: 'Sort by Student' }
    ]
  end
end
