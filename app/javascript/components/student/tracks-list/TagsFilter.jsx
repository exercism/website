import React, { useState } from 'react'
import { TagOptionList } from './TagOptionList'

export function TagsFilter({ options, dispatch }) {
  const [hidden, setHidden] = useState(true)
  const [selectedTags, setSelectedTags] = useState([])

  function handleSubmit(e) {
    e.preventDefault()

    dispatch({ type: 'tags.changed', payload: { tags: selectedTags } })
    setHidden(true)
  }

  function handleClose(e) {
    e.preventDefault()

    setHidden(true)
  }

  function resetFilters(e) {
    e.preventDefault()

    setSelectedTags([])
    dispatch({ type: 'tags.changed', payload: { tags: [] } })
  }

  return (
    <>
      <button onClick={() => setHidden(!hidden)} className="filter-btn">
        Filter by
      </button>
      <button onClick={resetFilters} className="reset-btn">
        Reset filters
      </button>
      {!hidden && (
        <div className="tag-option-list">
          <div className="md-container">
            <TagOptionList
              selectedTags={selectedTags}
              options={options}
              setSelectedTags={setSelectedTags}
              onSubmit={handleSubmit}
              onClose={handleClose}
            />
          </div>
        </div>
      )}
    </>
  )
}
