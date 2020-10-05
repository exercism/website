import React, { useState } from 'react'
import { TagOptionList } from './TagOptionList'

export function TagsFilter({ options, dispatch }) {
  const [hidden, setHidden] = useState(true)

  function handleSubmit(value) {
    dispatch({ type: 'tags.changed', payload: { tags: value } })
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
      {!hidden && <TagOptionList options={options} onSubmit={handleSubmit} />}
    </div>
  )
}
