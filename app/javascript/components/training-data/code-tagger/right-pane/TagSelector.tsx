import React from 'react'
import CreatableSelect from 'react-select/creatable'
import { Tags } from '../SolutionTagger.types'

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
      onChange={(e) => console.log(e)}
    />
  )
}

function formatTags(tags: Tags) {
  return tags.map((tag) => ({
    label: tag,
    value: tag,
  }))
}
