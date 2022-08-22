import React, { useCallback, useState } from 'react'
import RadioButton from './RadioButton'

export default function RadioGroup(): JSX.Element {
  const RADIO_DATA = [
    {
      label: 'Essential',
      tooltip: {
        title: 'If you mark this as Essential',
        body: 'Student is prompted heavily to action this before proceeding. Essential enhancement.',
      },
    },
    {
      label: 'Recommended',
      tooltip: {
        title: 'If you mark this as Recommended',
        body: 'Student is prompted to action this before proceeding, but not considered essential. High-value enhancement.',
      },
    },
    {
      label: 'Optional',
      tooltip: {
        title: 'If you mark this as Optional',
        body: 'Student is not prompted to action this before proceeding, entirely a low-value enhancement.',
      },
    },
  ]

  const [selected, setSelected] = useState('')

  const handleRadioCheck = useCallback(
    (e) => {
      setSelected(e.target.value)
    },
    [setSelected]
  )

  return (
    <div>
      {RADIO_DATA.map((i) => (
        <RadioButton
          key={i.label}
          checked={selected == i.label}
          onChange={handleRadioCheck}
          label={i.label}
          tooltip={i.tooltip}
        />
      ))}
    </div>
  )
}
