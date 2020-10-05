import React, { useState } from 'react'
import { TagOption } from './TagOption'

export function TagOptionList({ options, onSubmit, value, setValue }) {
  function handleChange(e, optionValue) {
    if (event.target.checked) {
      setValue(value.concat(optionValue))
    } else {
      setValue(value.filter((v) => v !== optionValue))
    }
  }

  return (
    <form onSubmit={onSubmit}>
      {options.map((option) => {
        return (
          <div key={option.category}>
            <p>{option.category}</p>
            {option.options.map((option) => {
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
          </div>
        )
      })}
      <button>Apply</button>
    </form>
  )
}
