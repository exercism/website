require 'test_helper'

class User::CombineAuthorsAndContributorsTest < ActiveSupport::TestCase
  test "uses authors up to limit" do
    users = create_list(:user, 6)
    authors = User.where('id < ?', users[5].id)
    contributors = User.where('id >= ?', users[5].id)

    combination = User::CombineAuthorsAndContributors.(authors, contributors, limit: 3)

    assert_equal combination, combination & authors
    assert_empty combination & contributors
  end

  test "uses contributors to pad authors to limit" do
    users = create_list(:user, 6)
    authors = User.where('id < ?', users[2].id)
    contributors = User.where('id >= ?', users[2].id)

    combination = User::CombineAuthorsAndContributors.(authors, contributors, limit: 3)

    assert_equal combination[0..1], combination[0..1] & authors
    assert_equal combination[2..], combination[2..] & contributors
  end

  test "uses contributors if there are no authors" do
    create_list(:user, 6)
    authors = User.none
    contributors = User.all

    combination = User::CombineAuthorsAndContributors.(authors, contributors, limit: 3)

    assert_empty combination & authors
    assert_equal combination, combination & contributors
  end

  test "default limit is set to 3" do
    users = create_list(:user, 6)
    authors = User.where('id < ?', users[5].id)
    contributors = User.where('id >= ?', users[5].id)

    combination = User::CombineAuthorsAndContributors.(authors, contributors)

    assert_equal 3, combination.count
  end
end
