module Contributing
  class TasksController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index]

    def index
      @data = AssembleTasks.(params)
    end
  end
end
