import React from 'react'
import CreatableSelect from 'react-select/creatable'
import { Tags } from '../CodeTagger.types'

export function TagSelector({
  tags,
  allTags,
  setSelectedTags,
}: {
  tags: Tags
  allTags: Tags
  setSelectedTags: React.Dispatch<React.SetStateAction<Tags>>
}): JSX.Element | null {
  if (!tags) return null
  return (
    <CreatableSelect
      className="creatable-select-component text-p-base"
      isMulti
      defaultValue={formatTags(tags)}
      options={formatTags(allTags)}
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
