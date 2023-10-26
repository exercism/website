import React from 'react'
import { Checkbox } from '@/components/common'
import { TagArray } from './ExerciseTagFilter.types'
import { capitalize } from '@/utils/capitalize'

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
      <h3 className="text-16 font-semibold mb-2">Filter by {groupName}</h3>

      {tagGroup.map((tagName, index) => (
        <Checkbox
          key={`${tagName}_${index}`}
          checked={checkedTags.indexOf(tagName) !== -1}
          setChecked={(isChecked) => {
            handleToggleTag(tagName, isChecked)
          }}
          className="leading-160 text-16"
        >
          {capitalize(tagName.split(':')[1])}
        </Checkbox>
      ))}
    </div>
  )
}
