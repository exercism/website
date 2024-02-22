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

# + signifies AND operation
# | signifies OR operation
# - negates a single token
# " wraps a number of tokens to signify a phrase for searching
# * at the end of a term signifies a prefix query
# ( and ) signify precedence
# ~N after a word signifies edit distance (fuzziness)
# ~N after a phrase signifies slop amount
