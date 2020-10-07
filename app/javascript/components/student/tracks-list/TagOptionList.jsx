import React, { useState } from 'react'
import { TagOption } from './TagOption'

export function TagOptionList({
  options,
  onSubmit,
  selectedTags,
  setSelectedTags,
}) {
  function handleChange(e, optionValue) {
    if (event.target.checked) {
      setSelectedTags(selectedTags.concat(optionValue))
    } else {
      setSelectedTags(selectedTags.filter((v) => v !== optionValue))
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
                  checked={selectedTags.includes(option.value)}
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
