import React, { ChangeEventHandler, useCallback, useState } from 'react'
import { Icon } from '../../../common'

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
        <RadioEssential
          key={i.label}
          checked={selected == i.label}
          onChange={handleRadioCheck}
          label={i.label}
        />
      ))}
    </div>
  )
}

function RadioEssential({
  label,
  checked,
  onChange,
}: {
  label: string
  checked: boolean
  onChange: ChangeEventHandler<HTMLInputElement>
}) {
  return (
    <label className="c-radio-wrapper mb-[13px]">
      <input checked={checked} onChange={onChange} value={label} type="radio" />
      <div className="row text-radio-essential">
        <div className="c-radio mr-16" />
        <div className="mr-[8.5px]">{label}</div>
        <Icon
          className="w-[15px] h-[15px] textColor6-filter"
          icon="info-circle"
          alt="Info"
        />
      </div>
    </label>
  )
}
