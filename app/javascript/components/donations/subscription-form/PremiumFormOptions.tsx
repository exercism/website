import React, { useState, useCallback } from 'react'
import { InitializedOption } from './form-options/PremiumInitializedOption'
import { CancellingOption } from './form-options/CancellingOption'
import { Links, PremiumPlan } from '../PremiumSubscriptionForm'
import { PremiumUpdatingOption } from './form-options/PremiumUpdatingOption'

type PremiumFormStatus = 'initialized' | 'cancelling' | 'updating'

export const PremiumFormOptions = ({
  links,
  otherPlan,
}: {
  links: Links
  otherPlan: PremiumPlan
}): JSX.Element | null => {
  const [status, setStatus] = useState<PremiumFormStatus>('initialized')
  const updateLink =
    otherPlan.type === 'month' ? links.updateToMonthly : links.updateToAnnual

  const handleInitialized = useCallback(() => {
    setStatus('initialized')
  }, [])

  const handleCancelling = useCallback(() => {
    setStatus('cancelling')
  }, [])

  const handleUpdating = useCallback(() => {
    setStatus('updating')
  }, [])

  switch (status) {
    case 'initialized':
      return links.cancel || updateLink ? (
        <InitializedOption
          otherPlan={otherPlan}
          onCancelling={handleCancelling}
          onUpdating={handleUpdating}
        />
      ) : null
    case 'updating':
      return updateLink ? (
        <PremiumUpdatingOption
          onClose={handleInitialized}
          otherPlan={otherPlan}
          updateLink={updateLink}
        />
      ) : null
    case 'cancelling':
      return links.cancel ? (
        <CancellingOption
          subscriptionType="premium"
          cancelLink={links.cancel}
          onClose={handleInitialized}
        />
      ) : null
  }
}
