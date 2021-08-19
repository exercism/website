import React, { useCallback } from 'react'
import currency from 'currency.js'

export const CustomAmountInput = ({
  onChange,
  selected,
  placeholder,
}: {
  onChange: (amount: currency) => void
  selected: boolean
  placeholder: string
}): JSX.Element => {
  const handleCustomAmountChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const parsedValue = parseInt(e.target.value)

      if (isNaN(parsedValue)) {
        onChange(currency(NaN))
        return
      }

      if (Math.sign(parsedValue) !== 1) {
        onChange(currency(NaN))
        return
      }

      onChange(currency(e.target.value))
    },
    [onChange]
  )

  const classNames = ['c-faux-input', selected ? 'selected' : ''].filter(
    (className) => className.length > 0
  )

  return (
    <label className={classNames.join(' ')}>
      <div className="icon">$</div>
      <input
        type="number"
        min="0"
        step="0.01"
        placeholder={placeholder}
        onChange={handleCustomAmountChange}
      />
    </label>
  )
}
