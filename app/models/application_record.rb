# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend HasMarkdownField

  def just_created? = id_previously_changed?
end
