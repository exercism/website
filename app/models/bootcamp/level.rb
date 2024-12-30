class Bootcamp::Level < ApplicationRecord
  self.table_name = "bootcamp_levels"

  has_markdown_field :content

  has_many :concepts, dependent: :destroy, foreign_key: :level_idx, primary_key: :idx, inverse_of: :level,
    class_name: "Bootcamp::Concept"
  has_many :exercises, dependent: :destroy, foreign_key: :level_idx, primary_key: :idx, inverse_of: :level,
    class_name: "Bootcamp::Exercise"

  def unlocked?
    Settings.instance.level_idx >= idx
  end
end
