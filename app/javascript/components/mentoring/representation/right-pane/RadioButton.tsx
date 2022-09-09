import React, { ChangeEventHandler } from 'react'
import { Icon } from '../../../common'
import { ExercismTippy } from '../../../misc/ExercismTippy'
import InfoTooltip, { Tooltip } from './InfoTooltip'

export default function RadioButton({
  label,
  value,
  checked,
  onChange,
  tooltip,
}: {
  label: string
  checked: boolean
  onChange: ChangeEventHandler<HTMLInputElement>
  tooltip: Tooltip
  value: string
}): JSX.Element {
  return (
    <label className="c-radio-wrapper mb-8 hover:cursor-pointer">
      <input checked={checked} onChange={onChange} value={value} type="radio" />
      <div className="row text-radio-essential">
        <div className="c-radio mr-16" />
        <div className="mr-8">{label}</div>
        <ExercismTippy
          content={<InfoTooltip title={tooltip.title} body={tooltip.body} />}
        >
          <div>
            <Icon
              className="w-[15px] h-[15px] filter-textColor6"
              icon="info-circle"
              alt="Info"
            />
          </div>
        </ExercismTippy>
      </div>
    </label>
  )
}
