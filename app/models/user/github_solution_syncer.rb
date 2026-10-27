class User::GithubSolutionSyncer < ApplicationRecord
  belongs_to :user

  validates :installation_id, :repo_full_name, presence: true
  validate :main_branch_name_is_valid, if: :main_branch_name_changed?

  enum processing_method: { commit: 1, pull_request: 2 }

  before_create do
    self.commit_message_template = DEFAULT_COMMIT_MESSAGE_TEMPLATE unless self.commit_message_template.present?
    self.path_template = DEFAULT_PATH_TEMPLATE unless self.path_template.present?
    self.processing_method = :pull_request
    self.sync_on_iteration_creation = true unless self.sync_on_iteration_creation == false
    self.sync_exercise_files = false unless self.sync_exercise_files.present?
  end

  def processing_method = super.to_sym
  def commit_to_main? = processing_method == :commit
  def create_pr? = processing_method == :pull_request

  # This follows the rules of git check-ref-format, limited to
  # a conservative set of characters and a sensible length.
  def self.valid_branch_name?(name)
    return false unless name.is_a?(String)
    return false unless name.length.between?(1, MAX_BRANCH_NAME_LENGTH)
    return false unless name.match?(BRANCH_NAME_CHARACTERS)
    return false if name.start_with?("-", "/")
    return false if name.end_with?("/", ".")
    return false if name.include?("..") || name.include?("//")

    name.split("/").none? { |part| part.start_with?(".") || part.end_with?(".lock") }
  end

  DEFAULT_COMMIT_MESSAGE_TEMPLATE = "[Sync $sync_object] $track_slug/$exercise_slug/$iteration_idx".freeze
  DEFAULT_PATH_TEMPLATE = "solutions/$track_slug/$exercise_slug/$iteration_idx".freeze
  MAX_BRANCH_NAME_LENGTH = 100
  BRANCH_NAME_CHARACTERS = %r{\A[A-Za-z0-9._/-]+\z}

  private
  def main_branch_name_is_valid
    return if self.class.valid_branch_name?(main_branch_name)

    errors.add(:main_branch_name, :invalid)
  end
end
