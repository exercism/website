import React from 'react'

export const SubscriptionForm = ({
  existingSubscriptionAmountinDollars,
  handleAmountChange,
  visible,
}: {
  existingSubscriptionAmountinDollars: number | null
  handleAmountChange: (e: any) => void
  visible: boolean
}): JSX.Element => {
  return (
    <div className={visible ? 'block' : 'hidden'}>
      {existingSubscriptionAmountinDollars != null ? (
        <>
          <div className="existing-subscription">
            <strong>
              You already donate ${existingSubscriptionAmountinDollars} per
              month to Exercism. Thank you!
            </strong>
            <br />
            To change or manage this go to <a href="#">Donation Settings</a>.
          </div>
          <div className="extra-cta">
            Extra {/*TODO: button should switch to the one-time tab */}
            <button>one-time donations</button> are still gratefully received!
          </div>
          <div className="form-cover" />
        </>
      ) : null}
      <div className="amounts">
        <div className="preset-amounts">
          <button
            className="btn-enhanced btn-l"
            value={16}
            onClick={handleAmountChange}
          >
            $16
          </button>
          <button
            className="btn-enhanced btn-l selected"
            value={32}
            onClick={handleAmountChange}
          >
            $32
          </button>
          <button
            className="btn-enhanced btn-l"
            value={64}
            onClick={handleAmountChange}
          >
            $64
          </button>
          <button
            className="btn-enhanced btn-l"
            value={128}
            onClick={handleAmountChange}
          >
            $128
          </button>
        </div>

        <h3>Or specify a custom amount:</h3>
        <label className="c-faux-input">
          <div className="icon">$</div>
          <input
            type="number"
            min="0"
            step="1"
            placeholder="Specify donation"
            onChange={handleAmountChange}
            onFocus={handleAmountChange}
          />
        </label>
      </div>
    </div>
  )
}
