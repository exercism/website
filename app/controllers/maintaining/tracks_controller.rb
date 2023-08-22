module Maintaining
  class TracksController < Maintaining::BaseController
    def show
      @track = Track.find(params[:id])

      @test_runner_sha = Tooling::RetrieveSha.(@track, 'test-runner')
      @representer_sha = Tooling::RetrieveSha.(@track, 'representer')
      @analyzer_sha = Tooling::RetrieveSha.(@track, 'analyzer')
    end
  end
end
