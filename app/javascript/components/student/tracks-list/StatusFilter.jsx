import React from 'react'

export function StatusFilter({ options, dispatch }) {
  function handleChange(e, value) {
    dispatch({ type: 'status.changed', payload: { status: value } })
  }

  return (
    <div>
      {options.map((option) => {
        return (
          <button
            key={option.value}
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
