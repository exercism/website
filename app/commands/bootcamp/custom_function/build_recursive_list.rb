class Bootcamp::CustomFunction::BuildRecursiveList
  include Mandate

  initialize_with :user, :names

  def call
    rec_names = build_name_tree([], names)
    user.bootcamp_custom_functions.active.where(name: rec_names).
      select(:name, :arity, :code)
  end

  private
  def build_name_tree(acc, names)
    names.each do |name|
      next if acc.include?(name)

      acc << name
      names_to_dependencies[name].to_a.each do |dep|
        next if acc.include?(dep)

        acc = build_name_tree(acc, [dep])
      end
    end
    acc
  end

  memoize
  def names_to_dependencies
    user.bootcamp_custom_functions.active.pluck(:name, :depends_on).to_h
  end
end
