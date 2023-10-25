import React from 'react'
import { usePanel } from '@/hooks/use-panel'
import { Icon } from '@/components/common'
import { Tags } from './ExerciseTagFilter.types'
import { ExerciseTagFilterGroup } from './ExerciseTagFilterGroup'
import { useExerciseTagFilter } from './useExerciseTagFilter'
import { Request } from '@/hooks/request-query'

export function ExerciseTagFilter({
  tags,
  setQuery,
  request,
}: {
  tags: Tags
  setQuery: (query: any) => void
  request: Request
}): JSX.Element | null {
  if (tags.length === 0) return null

  const { buttonAttributes, panelAttributes, setOpen, open } = usePanel()

  const { tagState, handleToggleTag } = useExerciseTagFilter({
    setQuery,
    request,
  })

  return (
    <div className="c-single-select mr-24">
      <button
        type="button"
        {...buttonAttributes}
        onClick={() => setOpen((o) => !o)}
      >
        <div className="value">Filter by tag</div>
        <Icon
          icon="chevron-down"
          alt="Click to change"
          className="action-icon"
        />
      </button>
      {open ? (
        <div {...panelAttributes} className="--options flex flex-wrap gap-12">
          {tags.map((tagCategory, index) => {
            return (
              <ExerciseTagFilterGroup
                tagCategory={tagCategory}
                key={index}
                handleToggleTag={handleToggleTag}
                tagState={request.query?.tags || tagState}
              />
            )
          })}
        </div>
      ) : null}
    </div>
  )
}
