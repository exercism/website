module SPI
  # Feeds the image generator, which draws a solution's share image without a
  # browser and so needs the data rather than the page.
  #
  # Being on SPI means the generator reaches this over the internal ALB. Fetching
  # the equivalent from the public site instead meant the lambda had to be
  # allowlisted by source IP in Cloudflare - the coupling that left every image
  # timing out for four days once bot mitigation was turned on.
  class SolutionImageDataController < BaseController
    def show
      solution = Solution.for!(
        params[:user_handle],
        params[:track_slug],
        params[:exercise_slug]
      )

      render json: SerializeSolutionImage.(solution)
    end
  end
end
