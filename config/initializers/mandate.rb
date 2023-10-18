require 'mandate'
require 'application_job'

class MandateJob < ApplicationJob
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

    cmd.constantize.new(*args, **kwargs).()
  end

  def __guard_prereq_jobs__!(prereq_jobs)
    return unless prereq_jobs.present?

    prereq_jobs.each do |job|
      jid = job[:job_id]

      # If the job is either in its queue, or in the retry queue
      # then we raise an exception and abort the job.
      if Sidekiq::Queue.all.find { |q| q.name == job[:queue_name] }.find_job(jid) ||
         Sidekiq::RetrySet.new.find_job(jid)
        raise PreqJobNotFinishedError, job_id
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
      if kwargs[:prereq_jobs]
        kwargs[:prereq_jobs] = kwargs[:prereq_jobs].map do |job|
          {
            job_id: job.provider_job_id,
            queue_name: job.queue_name
          }
        end
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
