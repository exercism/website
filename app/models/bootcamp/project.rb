class Bootcamp::Project < ApplicationRecord
  self.table_name = "bootcamp_projects"

  has_markdown_field :introduction

  # TODO: Fix the rubocop error
  has_many :exercises, class_name: "Bootcamp::Exercise" # rubocop:disable Rails/HasManyOrHasOneDependent

  def to_param = slug

  def icon_url = "/project-icons/#{slug}.svg"
end
