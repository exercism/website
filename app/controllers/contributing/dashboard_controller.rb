module Contributing
  class DashboardController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[show]

    def show
      @tracks = Track.all.index_by(&:id)
      @proofreading = build_tasks_list(action: :proofread)
      @improve_content = build_tasks_list(action: :improve, area: ["concept-exercise", "practice-exercise", :concept])
      @create_exercises = build_tasks_list(action: :create, area: %w[concept-exercise practice-exercise])
      @analyzer = build_tasks_list(area: :analyzer)
      @representer = build_tasks_list(area: :representer)
      @test_runner = build_tasks_list(area: "test-runner")
    end

    private
    def build_tasks_list(filters)
      Github::Task.where(filters).
        group(:track_id).
        count.
        sort_by { rand }.
        to_h
    end
  end
end
