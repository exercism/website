module Localization
  def self.table_name_prefix
    "localization_"
  end

  # rubocop:disable Style/BlockDelimiters
  mattr_reader :translations do {} end
  mattr_reader :use_cache do true end
  # rubocop:enable Style/BlockDelimiters
end
