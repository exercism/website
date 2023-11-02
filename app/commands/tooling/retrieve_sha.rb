class Tooling::RetrieveSha
  include Mandate

  initialize_with :track, :tool

  def call
    return "abcdef12345678" if Rails.env.development?

    resp = Exercism.ecr_client.describe_images(
      repository_name: repo_name,
      image_ids: [
        {
          image_tag: PRODUCTION_TAG
        }
      ]
    )
    image = resp.image_details.first
    return nil unless image

    image[:image_tags].delete(PRODUCTION_TAG)
    image[:image_tags].first
  rescue Aws::ECR::Errors::ImageNotFoundException,
         Aws::ECR::Errors::BadRequest,
         Aws::ECR::Errors::AccessDeniedException,
         Aws::ECR::Errors::RepositoryNotFoundException
    nil
  end

  private
  def repo_name = "#{track.slug}-#{tool}"

  PRODUCTION_TAG = "production".freeze
  private_constant :PRODUCTION_TAG
end
