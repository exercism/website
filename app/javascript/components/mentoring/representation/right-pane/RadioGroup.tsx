import React, { useCallback } from 'react'
import { HowImportantProps } from './HowImportant'
import RadioButton from './RadioButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const RADIO_VALUES = [
  'essential',
  'actionable',
  'non_actionable',
  'celebratory',
]
export default function RadioGroup({
  feedbackType,
  setFeedbackType,
}: HowImportantProps): JSX.Element {
  const { t } = useAppTranslation(
    'components/mentoring/representation/right-pane/RadioGroup.tsx'
  )
  const handleRadioCheck = useCallback(
    (e) => {
      setFeedbackType(e.target.value)
    },
    [setFeedbackType]
  )

  return (
    <div>
      {RADIO_VALUES.map((value) => (
        <RadioButton
          key={value}
          value={value}
          checked={feedbackType == value}
          onChange={handleRadioCheck}
          label={t(`radioGroup.${value}`)}
          tooltip={{
            title: t(`radioGroup.${value}TooltipTitle`),
            body: t(`radioGroup.${value}TooltipBody`),
          }}
        />
      ))}
    </div>
  )
}
