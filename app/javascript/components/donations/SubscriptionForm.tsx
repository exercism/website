import React from 'react'
import currency from 'currency.js'

export default ({
  amountInDollars,
}: {
  amountInDollars: number
}): JSX.Element => {
  return (
    <React.Fragment>
      <h2>
        You&apos;re currently donating{' '}
        {currency(amountInDollars, { precision: 2 }).format()} each month to
        Exercism.
      </h2>
      <p className="text-p-base">
        <strong>Thank you!</strong> Regular donations like yours allow us to
        anticipate our cashflow and make responsible decisions about hiring and
        growing Exercism.
      </p>
      <div className="options">
        <button>Change amount</button> or{' '}
        <button>cancel your recurring donation</button>
      </div>
    </React.Fragment>
  )
}
