Rails.application.config.assets.version = "1.0"

# class AssetUrlProcessor
#   def self.call(input)
#     # don't know why, copy from other processor
#     context = input[:environment].context_class.new(input)
#     data = input[:data].gsub(/url\(["']?(.+?)["']?\)/i) do |match|
#       asset = $1
#       if asset && asset !~ /(data:|http)/i
#         path = context.asset_path(asset)
#         "url(#{path})"
#       else
#         match
#       end
#     end

#     { data: data }
#   end
# end

# Sprockets.register_postprocessor 'text/css', AssetUrlProcessor
