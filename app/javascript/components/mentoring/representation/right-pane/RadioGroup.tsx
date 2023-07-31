import React, { useCallback } from 'react'
import { HowImportantProps } from './HowImportant'
import RadioButton from './RadioButton'

const RADIO_DATA = [
  {
    label: 'Essential',
    value: 'essential',
    tooltip: {
      title: 'If you mark this as Essential',
      body: 'Student is prompted heavily to action this before proceeding. Essential enhancement.',
    },
  },
  {
    label: 'Recommended',
    value: 'actionable',
    tooltip: {
      title: 'If you mark this as Recommended',
      body: 'Student is prompted to action this before proceeding, but not considered essential. High-value enhancement.',
    },
  },
  {
    label: 'Optional',
    value: 'non_actionable',
    tooltip: {
      title: 'If you mark this as Optional',
      body: 'Student is not prompted to action this before proceeding, entirely a low-value enhancement.',
    },
  },
  {
    label: 'Celebratory',
    value: 'celebratory',
    tooltip: {
      title: 'If you mark this as Celebratory',
      body: 'Student is not prompted to action this before proceeding, congratules the student on their solution.',
    },
  },
]
export default function RadioGroup({
  feedbackType,
  setFeedbackType,
}: HowImportantProps): JSX.Element {
  const handleRadioCheck = useCallback(
    (e) => {
      setFeedbackType(e.target.value)
    },
    [setFeedbackType]
  )

  return (
    <div>
      {RADIO_DATA.map((i) => (
        <RadioButton
          key={i.label}
          value={i.value}
          checked={feedbackType == i.value}
          onChange={handleRadioCheck}
          label={i.label}
          tooltip={i.tooltip}
        />
      ))}
    </div>
  )
}
