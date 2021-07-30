import React from 'react'

export const PaymentForm = ({
  handleAmountChange,
}: {
  handleAmountChange: (e: any) => void
}): JSX.Element => {
  return (
    <div className="form">
      <div className="amounts">
        <div className="preset-amounts">
          <button
            className="btn-enhanced btn-l"
            value={32}
            onClick={handleAmountChange}
          >
            $32
          </button>
          <button
            className="btn-enhanced btn-l"
            value={128}
            onClick={handleAmountChange}
          >
            $128
          </button>
          <button
            className="btn-enhanced btn-l"
            value={256}
            onClick={handleAmountChange}
          >
            $256
          </button>
          <button
            className="btn-enhanced btn-l"
            value={512}
            onClick={handleAmountChange}
          >
            $512
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
          />
        </label>
      </div>
    </div>
  )
}
