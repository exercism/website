# rubocop:disable Rails/HasManyOrHasOneDependent:

module CachedAssociations
  extend ActiveSupport::Concern

  class_methods do
    def cached_has_one(name, **options)
      has_one name, **options

      define_method(name) do
        assoc = association(name)
        return assoc.target if assoc.loaded?

        foreign_key = assoc.reflection.foreign_key
        klass       = assoc.klass

        klass.cached.find_by(foreign_key => id).tap do |record|
          assoc.target = record
          assoc.loaded!
        end
      end
    end

    def cached_belongs_to(name, **options)
      belongs_to name, **options

      define_method(name) do
        assoc = association(name)
        return assoc.target if assoc.loaded?

        foreign_key = assoc.reflection.foreign_key
        klass       = assoc.klass
        id          = public_send(foreign_key)

        return nil if id.nil?

        klass.cached.find(id).tap do |record|
          assoc.target = record
          assoc.loaded!
        end
      end
    end
  end
end
# rubocop:enable Rails/HasManyOrHasOneDependent:
