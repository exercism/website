require "test_helper"

class Git::Exercise::CheckForTestableChangesBetweenVersionsTest < ActiveSupport::TestCase
  test "true when any non-documentation files have changed" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: '13a73eb2f87254c30e7eea82a0f76f59111486aa'

    assert Git::Exercise::CheckForTestableChangesBetweenVersions.(exercise, 'satellite',
      'cfd8cf31bb9c90fd9160c82db69556a47f7c2a54')
  end

  test "false when only documentation files have changed" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: '87448759c3f447c0a20db660b278a628e299e602'

    refute Git::Exercise::CheckForTestableChangesBetweenVersions.(exercise, 'satellite',
      '13a73eb2f87254c30e7eea82a0f76f59111486aa')
  end
end
