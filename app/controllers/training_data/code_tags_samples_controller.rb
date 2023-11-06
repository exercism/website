module TrainingData
  class CodeTagsSamplesController < ApplicationController
    def index; end

    def show
      @sample = TrainingData::CodeTagsSample.first
    end
  end
end
