import React from 'react'
import currency from 'currency.js'
import { FormOptions } from './subscription-form/FormOptions'

type Links = {
  cancel: string
  update: string
}

export default ({
  amount,
  links,
}: {
  amount: currency
  links: Links
}): JSX.Element => {
  return (
    <React.Fragment>
      <h2>
        You&apos;re currently donating {amount.format()} each month to Exercism.
      </h2>
      <p className="text-p-base">
        <strong>Thank you!</strong> Regular donations like yours allow us to
        anticipate our cashflow and make responsible decisions about hiring and
        growing Exercism.
      </p>
      <FormOptions amount={amount} links={links} />
    </React.Fragment>
  )
}
