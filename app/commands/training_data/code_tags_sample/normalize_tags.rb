class TrainingData::CodeTagsSample::NormalizeTags
  include Mandate

  initialize_with :tags

  def call
    return nil if tags.nil?

    tags.flat_map { |tag| MAPPING.fetch(tag, tag) }.uniq
  end

  MAPPING = {
    'construct:global-variables' => ['construct:global-variable'],
    'construct:generator-expression' => ['construct:generator'],
    'technique:regular-expressions' => ['technique:regular-expressions'],
    'construct:double-precision:floating-point-number' => ['construct:double'],
    'construct:unsigned-int' => ['construct:uint'],
    'construct:unsigned-integral' => ['construct:uint'],
    'construct:nil' => ['construct:null'],
    'construct:none' => ['construct:null'],
    'construct:python-None' => ['construct:null'],
    'construct:python-raw-string' => ['construct:verbatim-string'],
    'construct:long-double' => ['construct:double'],
    'construct:long-long' => ['construct:long'],
    'construct:long-long-int' => ['construct:long'],
    'construct:elif' => ['construct:else'],
    'construct:elif-statement' => ['construct:else'],
    'construct:else-statement' => ['construct:else'],
    'construct:elseif' => ['construct:else'],
    'construct:if-else' => ['construct:if', 'construct:else'],
    'construct:if-statement' => ['construct:if', 'construct:else'],
    'construct:if-then-else' => ['construct:if', 'construct:else'],
    'construct:identity-test' => ['construct:type-test'],
    'construct:identity-comparison' => ['construct:equality'],
    'construct:setmetatable' => ['construct:meta-table'],
    'construct:positional-parameter' => [],
    'construct:positional-arguments' => []
  }.freeze
  private_constant :MAPPING
end
