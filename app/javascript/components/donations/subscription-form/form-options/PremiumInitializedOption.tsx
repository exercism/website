import React from 'react'
import { PremiumPlan } from '../../PremiumSubscriptionForm'

export const InitializedOption = ({
  onCancelling,
  onUpdating,
  otherPlan,
}: {
  onCancelling: () => void
  onUpdating: () => void
  otherPlan: PremiumPlan
}): JSX.Element => {
  return (
    <div className="options mb-12">
      You can&nbsp;
      <button type="button" onClick={onUpdating} className="text-a-subtle">
        change to {otherPlan.description}
      </button>
      &nbsp;or&nbsp;
      <button type="button" onClick={onCancelling} className="text-a-subtle">
        cancel Premium anytime.
      </button>
    </div>
  )
}
