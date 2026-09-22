class Country
  NAMES_FILE = Rails.root.join('config', 'country_names.yml')

  def self.name_for(code)
    return nil if code.blank?

    names[code.to_s.upcase]
  end

  def self.names
    @names ||= YAML.load_file(NAMES_FILE).freeze
  end
end
