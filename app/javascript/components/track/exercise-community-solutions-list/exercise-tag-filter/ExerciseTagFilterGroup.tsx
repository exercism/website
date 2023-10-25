import React from 'react'
import { Checkbox } from '@/components/common'
import { TagCategory, TagArray } from './ExerciseTagFilter.types'

export function ExerciseTagFilterGroup({
  tagCategory,
  tagState,
  handleToggleTag,
}: {
  tagCategory: TagCategory
  tagState: TagArray
  handleToggleTag: (tagName: string, isChecked: boolean) => void
}) {
  const groupName = Object.keys(tagCategory)[0]
  return (
    <div className="flex flex-col gap-8">
      <h1 className="text-h5">{groupName}</h1>

      {tagCategory[groupName].map((tagName, index) => (
        <Checkbox
          key={`${tagName}_${index}`}
          checked={tagState.indexOf(tagName) !== -1}
          setChecked={(isChecked) => {
            handleToggleTag(tagName, isChecked)
          }}
          className="leading-160"
        >
          {tagName.split(':')[1]}
        </Checkbox>
      ))}
    </div>
  )
}
