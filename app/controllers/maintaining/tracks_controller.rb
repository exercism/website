module Maintaining
  class TracksController < Maintaining::BaseController
    def show
      @track = Track.find(params[:id])

      @test_runner_sha = retrieve_tool_sha(@track, 'test-runner')
      @representer_sha = retrieve_tool_sha(@track, 'representer')
      @analyzer_sha = retrieve_tool_sha(@track, 'analyzer')
    end

    private
    def retrieve_tool_sha(track, tool)
      production_tag = "production".freeze
      repo_name = "#{track.slug}-#{tool}"
      resp = Exercism.ecr_client.describe_images(
        repository_name: repo_name,
        image_ids: [
          {
            image_tag: production_tag
          }
        ]
      )
      image = resp.image_details.first
      return nil unless image

      image[:image_tags].delete(production_tag)
      image[:image_tags].first
    rescue Aws::ECR::Errors::ImageNotFoundException,
           Aws::ECR::Errors::BadRequest,
           Aws::ECR::Errors::AccessDeniedException
      nil
    end
  end
end
