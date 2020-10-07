import React from 'react'

export function StatusFilter({ options, dispatch, ...props }) {
  const value = props.value || options[0].value
  function handleChange(e, value) {
    dispatch({ type: 'status.changed', payload: { status: value } })
  }

  return (
    <div>
      {options.map((option) => {
        return (
          <button
            key={option.value}
            disabled={option.value === value}
            onClick={(e) => {
              handleChange(e, option.value)
            }}
          >
            {option.label}
          </button>
        )
      })}
    </div>
  )
}
