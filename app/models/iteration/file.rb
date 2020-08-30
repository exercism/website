class Iteration::File < ApplicationRecord
  belongs_to :iteration
  attr_writer :content

  URI_REGEX = %r{s3://(?<bucket>[a-z-]+)/(?<key>.*)}.freeze

  before_create do
    self.uri = "s3://#{Exercism.config.aws_iterations_bucket}/#{Rails.env}/storage/#{SecureRandom.compact_uuid}"
  end

  # When the object is created we want to save
  # any content that has been passed in via the
  # attr_writer. We only want to do this on create
  # and never want to update or change this content.
  after_create do
    if @content
      s3_client.put_object(
        bucket: s3_bucket,
        key: s3_key,
        body: @content,
        acl: 'private'
      )
    end
  end

  def content
    s3_client.get_object(
      bucket: s3_bucket,
      key: s3_key
    ).body.read
  end

  def s3_bucket
    URI_REGEX.match(uri)[:bucket]
  end

  def s3_key
    URI_REGEX.match(uri)[:key]
  end

  private
  def s3_client
    ExercismConfig::SetupS3Client.()
  end
end
