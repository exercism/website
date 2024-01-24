require 'mandate'
require 'application_job'

class MandateJob < ApplicationJob
  class MandateJobNeedsRequeuing < RuntimeError
    attr_reader :wait

    def initialize(wait)
      @wait = wait
      super(nil)
    end
  end

  class PreqJobNotFinishedError < RuntimeError
    def initialize(job_id)
      @job_id = job_id
      super(nil)
    end

    def to_s
      "Unfinished job: #{job_id}"
    end

    private
    attr_reader :job_id
  end

  def perform(cmd, *args, **kwargs)
    __guard_prereq_jobs__!(kwargs.delete(:prereq_jobs))

    instance = cmd.constantize.new(*args, **kwargs)
    instance.define_singleton_method(:requeue_job!) { |wait| raise MandateJobNeedsRequeuing, wait }
    self.define_singleton_method :guard_against_deserialization_errors? do
      return true unless instance.respond_to?(:guard_against_deserialization_errors?)

      instance.guard_against_deserialization_errors?
    end

    instance.()
  rescue MandateJobNeedsRequeuing => e
    cmd.constantize.defer(
      *args,
      **kwargs.merge(wait: e.wait)
    )
  end

  def __guard_prereq_jobs__!(prereq_jobs)
    return unless prereq_jobs.present?

    prereq_jobs.each do |job|
      jid = job[:job_id]

      # If the job is either in its queue, or in the retry queue
      # then we raise an exception to abort the job and retry later.
      if Sidekiq::Queue.new(job[:queue_name]).find_job(jid) ||
         Sidekiq::RetrySet.new.find_job(jid)
        raise PreqJobNotFinishedError, jid
      end
    end
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
      # We need to convert the jobs to a hash before we serialize as there's no serialization
      # format for a job. We do this here to avoid cluttering the codebase with this logic.
      if (prereqs = kwargs.delete(:prereq_jobs))
        prereqs.map! do |job|
          {
            job_id: job.provider_job_id,
            queue_name: job.queue_name
          }
        end
        kwargs[:prereq_jobs] = prereqs if prereqs.present?
      end

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
