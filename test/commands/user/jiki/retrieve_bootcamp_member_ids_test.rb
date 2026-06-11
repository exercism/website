require 'test_helper'

class User::Jiki::RetrieveBootcampMemberIdsTest < ActiveSupport::TestCase
  test "includes bootcamp_attendee" do
    user = create(:user)
    user.data.update!(bootcamp_attendee: true)

    assert_includes User::Jiki::RetrieveBootcampMemberIds.(), user.id
  end

  test "includes bootcamp_mentor" do
    user = create(:user, bootcamp_mentor: true)

    assert_includes User::Jiki::RetrieveBootcampMemberIds.(), user.id
  end

  test "includes users enrolled on part 1" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_1: true)

    assert_includes User::Jiki::RetrieveBootcampMemberIds.(), user.id
  end

  test "includes users enrolled on part 2" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_2: true)

    assert_includes User::Jiki::RetrieveBootcampMemberIds.(), user.id
  end

  test "deduplicates users matching multiple criteria" do
    user = create(:user, bootcamp_mentor: true)
    user.data.update!(bootcamp_attendee: true)
    create(:user_bootcamp_data, user:, enrolled_on_part_1: true, enrolled_on_part_2: true)

    ids = User::Jiki::RetrieveBootcampMemberIds.()

    assert_equal 1, ids.count(user.id)
  end

  test "excludes users with no bootcamp data or roles" do
    create(:user)

    assert_empty User::Jiki::RetrieveBootcampMemberIds.()
  end
end
