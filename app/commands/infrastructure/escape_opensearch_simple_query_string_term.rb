class Infrastructure::EscapeOpensearchSimpleQueryStringTerm
  include Mandate

  initialize_with :term

  def call = term.gsub(/[|+\-"*()~\\]/) { |c| "\\#{c}" }
end
