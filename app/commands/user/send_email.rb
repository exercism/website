class User::SendEmail
  include Mandate

  initialize_with :emailable

  # TODO: Move this into mandate!
  def self.call(*args, &block)
    new(*args).(&block)
  end

  # This returns a boolean based on whether it succeeds or not
  def call
    raise "Block must be given for sending" unless block_given?

    # We start by doing checks to see if we should send based
    # on the state of the emailable. We hope to catch things
    # here to avoid locking
    return false unless emailable.email_pending?
    return false unless guard_needs_sending!

    # Do this first, so we can do it outside of the lock
    return false unless guard_user_wants_email!

    # TODO: (Required) Check for daily-batch preference

    # We now lock and recheck things. We do the rechecking in the locked
    # record to avoid race conditions.
    emailable.with_lock do
      return false unless emailable.email_pending?
      return false unless guard_needs_sending!

      yield

      emailable.email_sent!

      true
    end
  end

  private
  attr_reader :emailable

  def guard_needs_sending!
    return true if emailable.email_should_send?

    emailable.email_skipped!
    false
  end

  def guard_user_wants_email!
    conditions = [
      has_affirmative_communication_preference?,
      user.may_receive_emails?
    ]

    return true if conditions.all?

    emailable.email_skipped!
    false
  end

  def has_affirmative_communication_preference?
    return true unless emailable.email_communication_preferences_key

    user.communication_preferences&.send(emailable.email_communication_preferences_key)
  end

  memoize
  delegate :user, to: :emailable
end
