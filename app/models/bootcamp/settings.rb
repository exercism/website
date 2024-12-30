class Bootcamp::Settings < ApplicationRecord
  self.table_name = "bootcamp_settings"

  def self.instance
    @instance = first || create!
  end

  # DO NOT memoize these.
  def self.level_idx = instance.level_idx
end
