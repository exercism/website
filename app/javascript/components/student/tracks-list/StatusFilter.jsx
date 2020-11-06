import React from 'react'

export function StatusFilter({ options, dispatch, ...props }) {
  const value = props.value || options[0].value
  function handleChange(e, value) {
    dispatch({ type: 'status.changed', payload: { status: value } })
  }

  return (
    <div className="--status-filters">
      {options.map((option) => {
        // TODO: Populate .count once these
        // filters are moved client side
        const count = 20

        return (
          <button
            key={option.value}
            className={option.value === value ? '--selected' : ''}
            disabled={option.value === value}
            aria-label={option.aria_label}
            onClick={(e) => {
              handleChange(e, option.value)
            }}
          >
            {option.label}
            <span className="--count">{count}</span>
          </button>
        )
      })}
    </div>
  )
}
