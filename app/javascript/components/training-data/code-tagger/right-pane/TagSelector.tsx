import React from 'react'
import CreatableSelect from 'react-select/creatable'
import { Tags } from '../CodeTagger.types'

export function TagSelector({
  tags,
  setSelectedTags,
}: {
  tags: Tags
  setSelectedTags: React.Dispatch<React.SetStateAction<Tags>>
}): JSX.Element {
  return (
    <CreatableSelect
      className="creatable-select-component"
      isMulti
      options={formatTags(tags)}
      onChange={(selected): void =>
        setSelectedTags(selected.map((s) => s.label))
      }
    />
  )
}

function formatTags(tags: Tags) {
  return tags.map((tag) => ({
    label: tag,
    value: tag,
  }))
}
