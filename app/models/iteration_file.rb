class IterationFile < ApplicationRecord
  belongs_to :iteration

  before_save do
    self.digest = self.class.generate_digest(contents)
  end

  def self.generate_digest(contents)
    Digest::MD5.new.tap {|md5|
      md5.update(contents)
    }.hexdigest
  end
end
