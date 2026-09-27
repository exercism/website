# rails-i18n names European Portuguese `pt`, and the site serves it as `pt-PT`.
# rails-i18n only loads the files named after an available locale, so without
# this pt-PT would have no date or number formats, no Active Record messages and
# no plural rule. Its `pt` data is returned here under the served name.
require 'rails_i18n/common_pluralizations/one_other'

rails_i18n = Gem.loaded_specs.fetch('rails-i18n').full_gem_path

{ 'pt-PT': :pt }.select { |served, _| I18n.available_locales.include?(served) }.to_h do |served, source|
  file = File.join(rails_i18n, 'rails', 'locale', "#{source}.yml")
  locale = YAML.safe_load_file(file, permitted_classes: [Symbol]).fetch(source.to_s)
  plural = RailsI18n::Pluralization::OneOther.with_locale(source).fetch(source)

  [served, locale.deep_symbolize_keys.deep_merge(plural)]
end
