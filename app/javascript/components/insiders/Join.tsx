import React, { useCallback } from 'react'
import currency from 'currency.js'
import { redirectTo } from '@/utils'
import { ExercismStripeElements } from '@/components/donations/ExercismStripeElements'
import { StripeForm } from '@/components/donations/StripeForm'

export type JoinProps = {
  captchaRequired: boolean
  recaptchaSiteKey: string
  links: {
    returnTo: string
    paymentPending: string
  }
}

// The same subscription the editor's upsell modal offers, on its own page.
const MONTHLY_AMOUNT = currency(10)

// Just the form. StripeForm awaits `payment_intents/:id/succeeded`, which
// activates Insiders synchronously, before calling onSuccess - so by then the
// user is an Insider and can go straight back to wherever they came from.
// Payment methods that bounce through the bank come back via paymentPending,
// which carries the same return_to.
export default function Join({
  captchaRequired,
  recaptchaSiteKey,
  links,
}: JoinProps): JSX.Element {
  const handleSuccess = useCallback(
    () => redirectTo(links.returnTo),
    [links.returnTo]
  )

  return (
    <ExercismStripeElements
      mode="subscription"
      amount={MONTHLY_AMOUNT.intValue}
    >
      <StripeForm
        confirmParamsReturnUrl={links.paymentPending}
        captchaRequired={captchaRequired}
        userSignedIn={true}
        recaptchaSiteKey={recaptchaSiteKey}
        amount={MONTHLY_AMOUNT}
        onSuccess={handleSuccess}
        paymentIntentType="subscription"
      />
    </ExercismStripeElements>
  )
}
