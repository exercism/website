// i18n-key-prefix: tagTogglerButton
// i18n-namespace: components/track/build/analyzer-tags
import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { Tag } from './AnalyzerTags.types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/track/build/analyzer-tags')
  return (
    <button
      onClick={onClick}
      disabled={readOnly}
      className={assembleClassNames(
        'c-tag px-12 py-4 flex',
        readOnly ? readOnlyStyle : isActive ? toggledOnStyle : toggledOffStyle
      )}
    >
      {isActive ? t('tagTogglerButton.yes') : t('tagTogglerButton.no')}
    </button>
  )
}
