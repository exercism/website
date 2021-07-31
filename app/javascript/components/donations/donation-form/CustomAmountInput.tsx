import React, { useCallback } from 'react'

export const CustomAmountInput = ({
  onChange,
  defaultAmount,
  selected,
}: {
  onChange: (amount: number) => void
  defaultAmount: number
  selected: boolean
}): JSX.Element => {
  const handleCustomAmountChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const amount = parseInt(e.target.value)

      if (isNaN(amount)) {
        onChange(defaultAmount)

        return
      }

      onChange(amount)
    },
    [onChange, defaultAmount]
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
        step="1"
        placeholder="Specify donation"
        onChange={handleCustomAmountChange}
      />
    </label>
  )
}
