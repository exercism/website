class IterationFile < ApplicationRecord
  belongs_to :iteration

  before_save do
    self.digest = self.class.generate_digest(content)
  end

  def self.generate_digest(content)
    Digest::MD5.new.tap {|md5|
      md5.update(content)
    }.hexdigest
  end
end
