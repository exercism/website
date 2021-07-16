class TasksController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[tooltip]
  before_action :use_task

  def tooltip
    render_template_as_json
  end

  def use_task
    @task = Github::Task.find_by!(uuid: params[:uuid])
  end
end
