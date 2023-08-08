import React, { useCallback } from 'react'
import currency from 'currency.js'

export const CustomAmountInput = ({
  onChange,
  selected,
  placeholder,
  defaultValue,
  value,
  min = '0',
  className = '',
  onBlur,
}: {
  onChange: (amount: currency) => void
  onBlur?: () => void
  selected: boolean
  placeholder: string
  defaultValue?: currency
  value?: currency | string
  min?: string
  className?: string
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

  const classNames = [
    className,
    'c-faux-input',
    selected ? 'selected' : '',
  ].filter((className) => className.length > 0)

  return (
    <label className={classNames.join(' ')}>
      <div className="icon">$</div>
      <input
        type="number"
        min={min}
        step="0.01"
        onBlur={onBlur}
        placeholder={placeholder}
        onChange={handleCustomAmountChange}
        value={getValue(value)}
        defaultValue={defaultValue?.value}
      />
    </label>
  )
}

type InputValue = string | currency | undefined

// type guard to make sure that TS knows when value is of type currency
function isCurrency(obj: InputValue): obj is currency {
  return obj !== null && typeof obj === 'object' && 'value' in obj
}

function getValue(value: InputValue): string | number | undefined {
  if (isCurrency(value) && isNaN(value.value)) {
    // this gets rid of errors when input isNaN
    return ''
  }
  return typeof value === 'string' ? value : value?.value
}
