require 'mandate'
require 'application_job'

class MandateJob < ApplicationJob
  def perform(cmd, ...)
    cmd.constantize.new(...).()
  end
end

module Mandate
  module CallInjector
    def defer(...)
      MandateJob.new(self.name, ...)
    end
  end
end
