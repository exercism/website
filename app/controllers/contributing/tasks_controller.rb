module Contributing
  class TasksController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index]
    before_action :use_task, only: [:tooltip]

    def index
      @data = AssembleTasks.(params)
    end

    def tooltip
      render_template_as_json
    end

    private
    def use_task
      @task = Github::Task.find_by!(uuid: params[:uuid])
    end
  end
end
