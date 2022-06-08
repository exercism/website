class Github::Task < ApplicationRecord
  disable_sti!

  belongs_to :track, optional: true

  enum action: {
    create: 0,
    fix: 1,
    improve: 2,
    proofread: 3,
    sync: 4
  }, _suffix: true

  enum knowledge: {
    none: 0,
    elementary: 1,
    intermediate: 2,
    advanced: 3
  }, _prefix: true

  enum area: {
    analyzer: 0,
    "concept-exercise": 1,
    concept: 2,
    generator: 3,
    "practice-exercise": 4,
    representer: 5,
    "test-runner": 6
  }, _suffix: true

  enum size: {
    tiny: 0,
    small: 1,
    medium: 2,
    large: 3,
    massive: 4
  }, _prefix: true

  enum type: {
    ci: 0,
    coding: 1,
    content: 2,
    docker: 3,
    docs: 4
  }, _suffix: true

  before_validation do
    set_track_from_repo_url unless track
  end

  %i[action knowledge area size type].each do |type|
    define_method type do
      super()&.to_sym
    end
  end

  before_create do
    self.uuid = SecureRandom.compact_uuid if self.uuid.blank?
  end

  private
  def set_track_from_repo_url
    self.track_id = Track.where(repo_url:).pick(:id)
  end

  def repo_url
    issue_url.
      gsub(%r{/issues/\d+}, '').
      gsub(/-(test-runner|analyzer|representer)$/, '')
  end
end
