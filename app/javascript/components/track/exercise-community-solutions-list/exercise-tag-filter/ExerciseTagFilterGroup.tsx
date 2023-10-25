import React from 'react'
import { Checkbox } from '@/components/common'
import { TagArray } from './ExerciseTagFilter.types'

export function ExerciseTagFilterGroup({
  tagGroup,
  checkedTags,
  handleToggleTag,
  groupName,
}: {
  tagGroup: TagArray
  checkedTags: TagArray
  handleToggleTag: (tagName: string, isChecked: boolean) => void
  groupName: string
}) {
  return (
    <div className="flex flex-col gap-8">
      <h1 className="text-h5">{groupName}</h1>

      {tagGroup.map((tagName, index) => (
        <Checkbox
          key={`${tagName}_${index}`}
          checked={checkedTags.indexOf(tagName) !== -1}
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
