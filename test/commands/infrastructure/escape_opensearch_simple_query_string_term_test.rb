require "test_helper"

class Infrastructure::EscapeOpensearchSimpleQueryStringTermTest < ActiveSupport::TestCase
  [
    ['abc', 'abc'],
    ['a+c', 'a\\+c'],
    ['a|c', 'a\\|c'],
    ['a-c', 'a\\-c'],
    ['a"c', 'a\\"c'],
    ['a*c', 'a\\*c'],
    ['a(c', 'a\\(c'],
    ['a)c', 'a\\)c'],
    ['a~c', 'a\\~c'],
    ['a\\c', 'a\\\\c']
  ].each do |(term, expected)|
    test "escape '#{term}' as '#{expected}'" do
      assert_equal expected, Infrastructure::EscapeOpensearchSimpleQueryStringTerm.(term)
    end
  end
end
