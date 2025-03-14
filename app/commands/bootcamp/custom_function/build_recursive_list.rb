class Bootcamp::CustomFunction::BuildRecursiveList
  include Mandate

  initialize_with :user, :selected

  def call
    active_fns = user.bootcamp_custom_functions.active

    available = active_fns.pluck(:name).map do |name|
      {
        name:,
        dependencies: build_name_tree([], [name]).reject { |n| n == name },
        selected: selected.include?(name)
      }
    end

    for_interpreter = active_fns.select(:name, :arity, :code).map(&:attributes)

    {
      available:,
      for_interpreter:
    }
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
