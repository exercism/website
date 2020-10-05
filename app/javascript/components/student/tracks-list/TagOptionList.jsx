import React, { useState } from 'react'
import { TagOption } from './TagOption'

export function TagOptionList({ options, onSubmit }) {
  const [value, setValue] = useState([])

  function handleChange(e, optionValue) {
    if (event.target.checked) {
      setValue(value.concat(optionValue))
    } else {
      setValue(value.filter((v) => v !== optionValue))
    }
  }

  function handleSubmit(e) {
    e.preventDefault()

    onSubmit(value)
  }

  return (
    <form onSubmit={handleSubmit}>
      {options.map((option) => {
        return (
          <TagOption
            key={option.value}
            onChange={handleChange}
            checked={value.indexOf(option.value) >= 0}
            label={option.label}
            value={option.value}
          />
        )
      })}
      <button>Apply</button>
    </form>
  )
}
