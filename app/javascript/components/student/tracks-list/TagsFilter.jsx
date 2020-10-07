import React, { useState } from 'react'
import { TagOptionList } from './TagOptionList'

export function TagsFilter({ options, dispatch }) {
  const [hidden, setHidden] = useState(true)
  const [selectedTags, setSelectedTags] = useState([])

  function handleSubmit(e) {
    e.preventDefault()

    dispatch({ type: 'tags.changed', payload: { tags: value } })
  }

  function resetFilters(e) {
    e.preventDefault()

    setValue([])
    dispatch({ type: 'tags.changed', payload: { tags: [] } })
  }

  return (
    <div>
      <button
        onClick={() => {
          setHidden(!hidden)
        }}
      >
        Filter by
      </button>
      <button onClick={resetFilters}>Reset filters</button>
      {!hidden && (
        <div>
          <TagOptionList
            value={value}
            options={options}
            setValue={setValue}
            onSubmit={handleSubmit}
          />
          <button
            onClick={() => {
              setHidden(true)
            }}
          >
            Close
          </button>
        </div>
      )}
    </div>
  )
}
