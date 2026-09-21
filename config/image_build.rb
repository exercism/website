# Building the production image boots the app to compile its assets, and the
# build has no access to the AWS account that Exercism's config and secrets
# live in. These stubs stand in for both, so the build never contacts AWS.
# The two values compiled into the JS are passed in. Everything else is only
# read in passing while booting, so the config gem's development settings do.
ENV["SECRET_KEY_BASE_DUMMY"] = "1"
ENV["AWS_EC2_METADATA_DISABLED"] = "true"

passed_in = ->(name) { ENV[name].presence || raise("#{name} must be set to build the image") }

config = YAML.load_file(File.join(Gem.loaded_specs["exercism-config"].gem_dir, "settings", "local.yml")).merge(
  "website_assets_host" => passed_in.("WEBSITE_ASSETS_HOST"),
  "sentry_js_dsn" => passed_in.("SENTRY_JS_DSN"),
  "website_url" => "https://exercism.org",
  "websockets_url" => "wss://exercism.org",
  "sentry_rails_dsn" => nil,
  "aws_attachments_region" => "eu-west-2",
  "aws_attachments_bucket" => "attachments"
)

Aws.config[:dynamodb] = {
  stub_responses: {
    scan: { items: config.map { |id, value| { "id" => id, "value" => value } } }
  }
}

Aws.config[:secretsmanager] = {
  stub_responses: {
    get_secret_value: { secret_string: "{}" }
  }
}
