# Exercism.s3_client (from the exercism-config gem) builds a brand new
# Aws::S3::Client on every call. The aws-sdk keeps a process-global
# connection pool (Seahorse::Client::NetHttp::ConnectionPool), so TCP/TLS
# connections are still reused across those throwaway clients, but the
# default http_idle_timeout of 5 seconds means low-QPS paths (e.g. web
# requests fetching submission files) pay a fresh TLS handshake to S3
# almost every time.
#
# We override the gem's method here to:
# - memoize a single, thread-safe client per process
# - raise http_idle_timeout so pooled connections survive quiet spells
#
# TODO: Move this upstream into exercism-config.
module Exercism
  def self.s3_client
    @s3_client ||= begin
      require 'aws-sdk-s3'

      Aws::S3::Client.new(
        ExercismConfig::GenerateAwsSettings.().merge(
          force_path_style: true,
          http_idle_timeout: 60
        )
      )
    end
  end
end
