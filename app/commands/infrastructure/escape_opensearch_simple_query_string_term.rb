class Infrastructure::EscapeOpensearchSimpleQueryStringTerm
  include Mandate

  initialize_with :term

  def call
    # See https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html#simple-query-string-syntax
    term.gsub(/[|+\-"*()~\\]/) { |c| "\\#{c}" }
  end
end
