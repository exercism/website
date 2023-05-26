import React from 'react'
import { PremiumFormOptions } from './subscription-form/PremiumFormOptions'
import { SubscriptionFormProps } from './SubscriptionForm'

const INTERVAL_INFO: Record<Intervals, string> = {
  month: "monthly plan ($9.99/month). If you'd like to move to our annual plan",
  year: "annual plan ($99.99/year). If you'd like to move to our monthly plan ($9.99)",
  lifetime: '',
}

type Intervals = 'year' | 'month' | 'lifetime'
export default ({
  amount,
  links,
  interval,
}: SubscriptionFormProps & { interval: Intervals }): JSX.Element => {
  return (
    <React.Fragment>
      <h2>
        You&apos;re {interval !== 'lifetime' && 'currently'} subscribed to
        Exercism Premium.
      </h2>
      <p className="text-p-base">
        You&apos;re currently on the {INTERVAL_INFO[interval]} please contact
        loretta@exercism.org. to cancel your subscription, please use the
        [paypal dashboard](....). if you&apos;d like even more features, you can
        join [exercism insiders](...) and get premium for free forever, by
        making a [one time donation](open $499 modal) of $499.
      </p>
      <PremiumFormOptions amount={amount} links={links} />
    </React.Fragment>
  )
}

// you're currently on the monthly plan ($9.99/month). if you'd like to move to our annual plan, please contact loretta@exercism.org. to cancel your subscription, please use the [paypal dashboard](....). if you'd like even more features, you can join [exercism insiders](...) and get premium for free forever, by making a [one time donation](open $499 modal) of $499.
