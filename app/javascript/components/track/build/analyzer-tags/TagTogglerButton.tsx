import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { Tag } from './AnalyzerTags.types'

const toggledOnStyle =
  'border-darkGreen text-everyoneLovesAGreen bg-[var(--backgroundColorConceptMastered)]'
const toggledOffStyle =
  'border-red text-red bg-[(var(--backgroundColorExerciseStatusTagLocked)]'
const readOnlyStyle = 'border-transparent text-textColor6 bg-backgroundColorA'

export function TagTogglerButton({
  isActive,
  onClick,
  readOnly,
}: {
  isActive: boolean
  onClick: () => void
  readOnly: boolean
}) {
  return (
    <button
      onClick={onClick}
      disabled={readOnly}
      className={assembleClassNames(
        'c-tag px-12 py-4 flex',
        readOnly ? readOnlyStyle : isActive ? toggledOnStyle : toggledOffStyle
      )}
    >
      {isActive ? 'Yes' : 'No'}
    </button>
  )
}
