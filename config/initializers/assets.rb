Rails.application.configure do
  config.assets.version = "1.0"
  config.assets.paths << 'app/images'
  config.assets.paths << 'app/fonts'
  config.assets.paths << '.built-assets'
end

# This code is taken from https://github.com/rails/propshaft/blob/main/lib/propshaft/server.rb#L8
# and modified to ignore esbuild derrived chunks and related files

# This stops it locally
require 'propshaft/server'
module Propshaft
  class Server
    def call(env)
      path, digest = extract_path_and_digest(env)

      esbuild_split_asset = path.include?('-') && path.ends_with?('.js')
      if (asset = @assembly.load_path.find(path)) && (asset.fresh?(digest) || esbuild_split_asset)
        compiled_content = @assembly.compilers.compile(asset)

        [
          200,
          {
            "Content-Length" => compiled_content.length.to_s,
            "Content-Type" => asset.content_type.to_s,
            "Accept-Encoding" => "Vary",
            "ETag" => asset.digest,
            "Cache-Control" => "public, max-age=31536000, immutable"
          },
          [compiled_content]
        ]
      else
        [404, { "Content-Type" => "text/plain", "Content-Length" => "9" }, ["Not found"]]
      end
    end
  end
end

# # This stops it in production
class Propshaft::Asset
  def digested_path
    return logical_path if digested_by_esbuild?
    return logical_path if already_digested?

    logical_path.sub(/\.(\w+)$/) { |ext| "-#{digest}#{ext}" }
  end

  def digested_by_esbuild?
    logical_path.to_s =~ /-([0-9A-Z]{8})\.js/
  end
end
