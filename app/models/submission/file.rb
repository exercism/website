class Submission::File < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :submission

  attr_writer :content

  URI_REGEX = %r{s3://(?<bucket>[a-z0-9-]+)/(?<key>.*)}

  before_create do
    self.uri = generate_uri
  end

  # When the object is created we want to save
  # any content that has been passed in via the
  # attr_writer. We only want to do this on create
  # and never want to update or change this content.
  #
  # Note that we don't use after_create_commit as
  # we want this to be done as quickly as possible
  # and all data that is used is present (no risk of
  # a race condition).
  after_create do
    upload_content_to_s3!(content) if @content
  end

  def upload_to_s3!
    return if uri

    update(uri: generate_uri) if self.uri.blank?
    upload_content_to_s3!(@content)
  end

  def content
    utf8_content.tap(&:to_json)
  rescue JSON::GeneratorError
    "[Invalid Unicode]"
  end

  memoize
  def utf8_content = String.new(raw_content, encoding: 'utf-8')

  private
  def generate_uri
    "s3://#{Exercism.config.aws_submissions_bucket}/#{Rails.env}/storage/#{SecureRandom.compact_uuid}"
  end

  def upload_content_to_s3!(_content)
    Exercism.s3_client.put_object(
      bucket: s3_bucket,
      key: s3_key,
      body: @content,
      acl: 'private'
    )
  end

  def raw_content
    # We memoize this method
    # Don't use `.presence?` here as the encoding might be incorrect
    # and then the string check will raise an exception
    return @raw_content if @raw_content && @raw_content != ""

    # Check to see if content has been passed in
    return @content if @content && @content != ""

    return file_contents if uri.empty?

    attempts = 0
    begin
      attempts += 1
      @raw_content = Exercism.s3_client.get_object(
        bucket: s3_bucket,
        key: s3_key
      ).body.read
    rescue Aws::Sigv4::Errors::MissingCredentialsError, Aws::Errors::MissingCredentialsError
      raise if attempts >= 3

      sleep(attempts)
      retry
    end
  rescue Aws::S3::Errors::NoSuchKey
    ""
  end

  def s3_bucket
    URI_REGEX.match(uri)[:bucket]
  end

  def s3_key
    URI_REGEX.match(uri)[:key]
  end
end
