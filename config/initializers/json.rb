# https://github.com/ohler55/oj/blob/develop/pages/JsonGem.md
# https://github.com/ohler55/oj/blob/develop/pages/Rails.md

require 'oj'
Oj.optimize_rails

# rubocop:disable Security/JSONLoad
class JSONWithIndifferentAccess
  def self.load(str)
    JSON.load(str, nil, symbolize_names: true, create_additions: false)
    # obj.freeze
    # obj
  end

  def self.dump(obj)
    JSON.dump(obj)
  end
end
# rubocop:enable Security/JSONLoad
