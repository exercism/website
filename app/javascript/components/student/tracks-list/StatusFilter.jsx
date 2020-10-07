import React from 'react'

export function StatusFilter({ options, dispatch, ...props }) {
  const value = props.value || options[0].value
  function handleChange(e, value) {
    dispatch({ type: 'status.changed', payload: { status: value } })
  }

  return (
    <div className="status-filters">
      {options.map((option) => {
        // TODO: Populate .count once these
        // filters are moved client side
        return (
          <button
            key={option.value}
            className={option.value === value ? 'selected' : ''}
            disabled={option.value === value}
            onClick={(e) => {
              handleChange(e, option.value)
            }}
          >
            {option.label}
            <span className="count">20</span>
          </button>
        )
      })}
    </div>
  )
}
