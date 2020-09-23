class Test::Components::Mentoring::MentorSolutionsListsController < ApplicationController
  def show
    @sort_options = [
      { value: 'recent', label: 'Sort by Most Recent' },
      { value: 'exercise', label: 'Sort by Exercise' },
      { value: 'student', label: 'Sort by Student' }
    ]
  end
end
