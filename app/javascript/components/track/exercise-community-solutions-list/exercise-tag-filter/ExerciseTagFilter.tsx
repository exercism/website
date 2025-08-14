import React from 'react'
import { usePanel } from '@/hooks/use-panel'
import { Icon } from '@/components/common'
import { ExerciseTagFilterGroup } from './ExerciseTagFilterGroup'
import { useExerciseTagFilter } from './useExerciseTagFilter'
import type { Tags } from './ExerciseTagFilter.types'
import type { Request } from '@/hooks/request-query'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function ExerciseTagFilter({
  tags,
  setQuery,
  request,
}: {
  tags: Tags
  setQuery: (query: any) => void
  request: Request
}): JSX.Element | null {
  const { t } = useAppTranslation(
    'components/track/exercise-community-solutions-list'
  )
  if (Object.keys(tags).length === 0) return null

  const { buttonAttributes, panelAttributes, setOpen, open } = usePanel({
    placement: 'bottom-start',
    arrow: true,
  })

  const { tagState, handleToggleTag } = useExerciseTagFilter({
    setQuery,
    request,
  })

  return (
    <div className="c-single-select md:w-[150px] w-100">
      <button
        type="button"
        {...buttonAttributes}
        onClick={() => setOpen((o) => !o)}
      >
        <div className="value">
          {t('exerciseTagFilter.exerciseTagFilter.filter')}
          {showSelectedTagCount(tagState)}
        </div>
        <Icon
          icon="chevron-down"
          alt="Click to change"
          className="action-icon"
        />
      </button>
      {open ? (
        <div
          {...panelAttributes}
          className="--options flex flex-wrap gap-24 w-[200%] mt-8 !p-16"
        >
          {Object.keys(tags).map((tagCategory: string, index) => {
            return (
              <ExerciseTagFilterGroup
                groupName={tagCategory}
                tagGroup={tags[tagCategory]}
                key={`${tagCategory}_${index}`}
                handleToggleTag={handleToggleTag}
                checkedTags={request.query?.tags || tagState}
              />
            )
          })}
        </div>
      ) : null}
    </div>
  )
}

function showSelectedTagCount(selectedTags: string[]) {
  const length = selectedTags.length
  if (length === 0) return null

  return ` (${length})`
}
