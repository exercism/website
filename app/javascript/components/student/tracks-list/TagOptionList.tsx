import React, { useCallback } from 'react'
import { TagOption as TagOptionProps } from '../TracksList'
import { TagOption } from './TagOption'

export const TagOptionList = ({
  options,
  onSubmit,
  onClose,
  selectedTags,
  setSelectedTags,
}: {
  options: readonly TagOptionProps[]
  onSubmit: () => void
  onClose: () => void
  selectedTags: string[]
  setSelectedTags: (tags: string[]) => void
}): JSX.Element => {
  function handleChange(
    e: React.ChangeEvent<HTMLInputElement>,
    optionValue: string
  ) {
    if (e.target.checked) {
      setSelectedTags(selectedTags.concat(optionValue))
    } else {
      setSelectedTags(selectedTags.filter((v) => v !== optionValue))
    }
  }

  const handleClose = useCallback(
    (e) => {
      e.preventDefault()
      onClose()
    },
    [onClose]
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      onSubmit()
    },
    [onSubmit]
  )

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <div className="--categories">
        {options.map((option) => {
          return (
            <div key={option.category} className="--category">
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
      <footer className="--buttons">
        <button className="--apply-btn">Apply</button>
        <button className="--close-btn" onClick={handleClose}>
          Close
        </button>
      </footer>
    </form>
  )
}
