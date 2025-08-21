class Bootcamp::CustomFunction::BuildRecursiveList
  include Mandate

  initialize_with :user, :selected

  def call
    active_fns = user.bootcamp_custom_functions.active.order(:name).to_a
    for_interpreter = active_fns.map do |fn|
      fn.attributes.symbolize_keys.slice(:name, :arity, :code, :description).merge(
        dependencies: build_name_tree([], [fn.name]).reject { |n| n == fn.name }.sort
      )
    end

    {
      selected:,
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
