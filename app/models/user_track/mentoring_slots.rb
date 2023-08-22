module UserTrack::MentoringSlots
  extend Mandate::Memoize

  MENTORING_SLOT_THRESHOLDS = [0, 0, 100, 500].freeze

  def has_available_mentoring_slot? = num_available_mentoring_slots.positive?

  memoize
  def num_locked_mentoring_slots
    return 0 if user.insider?

    MENTORING_SLOT_THRESHOLDS.count { |threshold| user.reputation < threshold }
  end

  memoize
  def num_available_mentoring_slots
    num = MENTORING_SLOT_THRESHOLDS.size - num_used_mentoring_slots - num_locked_mentoring_slots
    num.positive? ? num : 0
  end

  memoize
  def num_used_mentoring_slots
    active_mentoring_discussions.where(external: false).count + pending_mentoring_requests.count
  end

  memoize
  def percentage_to_next_mentoring_slot
    return nil if num_locked_mentoring_slots.zero?

    next_slot_rep = rep_for_next_mentoring_slot
    current_slot_rep = MENTORING_SLOT_THRESHOLDS[MENTORING_SLOT_THRESHOLDS.length - num_locked_mentoring_slots - 1]

    (user.reputation - current_slot_rep).to_f / (next_slot_rep - current_slot_rep) * 100
  end

  memoize
  def rep_for_next_mentoring_slot
    return nil if num_locked_mentoring_slots.zero?

    MENTORING_SLOT_THRESHOLDS[MENTORING_SLOT_THRESHOLDS.length - num_locked_mentoring_slots]
  end
end
