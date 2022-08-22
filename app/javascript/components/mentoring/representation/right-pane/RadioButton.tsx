import React, { ChangeEventHandler } from 'react'
import { Icon } from '../../../common'
import { ExercismTippy } from '../../../misc/ExercismTippy'
import InfoTooltip, { Tooltip } from './InfoTooltip'

export default function RadioButton({
  label,
  checked,
  onChange,
  tooltip,
}: {
  label: string
  checked: boolean
  onChange: ChangeEventHandler<HTMLInputElement>
  tooltip: Tooltip
}): JSX.Element {
  return (
    <label className="c-radio-wrapper mb-[13px] hover:cursor-pointer">
      <input checked={checked} onChange={onChange} value={label} type="radio" />
      <div className="row text-radio-essential">
        <div className="c-radio mr-16" />
        <div className="mr-[8.5px]">{label}</div>
        <ExercismTippy
          content={<InfoTooltip title={tooltip.title} body={tooltip.body} />}
        >
          <div>
            <Icon
              className="w-[15px] h-[15px] textColor6-filter"
              icon="info-circle"
              alt="Info"
            />
          </div>
        </ExercismTippy>
      </div>
    </label>
  )
}
