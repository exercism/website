class Bootcamp::Project < ApplicationRecord
  self.table_name = "bootcamp_projects"

  has_markdown_field :introduction

  # TODO: Fix the rubocop error
  has_many :exercises, class_name: "Bootcamp::Exercise" # rubocop:disable Rails/HasManyOrHasOneDependent

  def self.unlocked
    where(id: Bootcamp::Exercise.unlocked.select(:project_id))
  end

  def locked? = !unlocked?
  def unlocked? = Bootcamp::Exercise.unlocked.where(project_id: id).exists?

  def to_param = slug

  def icon_url = "#{Exercism.config.website_icons_host}/bootcamp/projects/#{slug}.svg"
end
