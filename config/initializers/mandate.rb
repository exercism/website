require 'mandate'
require 'application_job'

class MandateJob < ApplicationJob
  def perform(cmd, ...)
    cmd.constantize.new(...).()
  end
end

module Mandate
  module ActiveJobQueuer
    def self.extended(base)
      class << base
        def queue_as(queue)
          @active_job_queue = queue
        end

        def active_job_queue
          @active_job_queue || :default
        end
      end
    end

    def defer(*args, wait: nil, **kwargs)
      MandateJob.set(
        queue: active_job_queue,
        wait:
      ).perform_later(self.name, *args, **kwargs)
    end
  end

  def self.included(base)
    # Upstream
    base.extend(Memoize)
    base.extend(CallInjector)
    base.extend(InitializerInjector)

    # New
    base.extend(ActiveJobQueuer)
  end
end
