import React, { useState } from 'react'
import { TagOption } from './TagOption'

export function TagOptionList({
  options,
  onSubmit,
  onClose,
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
      <div className="categories">
        {options.map((option) => {
          return (
            <div key={option.category} className="category">
              <h4>{option.category}</h4>
              {option.options.map((option) => (
                <TagOption
                  key={option.value}
                  onChange={handleChange}
                  checked={selectedTags.includes(option.value)}
                  label={option.label}
                  value={option.value}
                />
              ))}
            </div>
          )
        })}
      </div>
      <footer className="buttons">
        <button className="apply-btn">Apply</button>
        <button className="close-btn" onClick={onClose}>
          Close
        </button>
      </footer>
    </form>
  )
}
