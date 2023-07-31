import React, { ChangeEventHandler } from 'react'
import { Icon } from '../../../common'
import { ExercismTippy } from '../../../misc/ExercismTippy'
import InfoTooltip, { Tooltip } from './InfoTooltip'

export default function RadioButton({
  label,
  value,
  checked,
  defaultChecked,
  onChange,
  tooltip,
  name,
  labelClassName,
  className,
}: {
  label: string
  checked?: boolean
  defaultChecked?: boolean
  onChange?: ChangeEventHandler<HTMLInputElement>
  tooltip?: Tooltip
  value: string
  name?: string
  labelClassName?: string
  className?: string
}): JSX.Element {
  return (
    <label className={`c-radio-wrapper mb-8 hover:cursor-pointer ${className}`}>
      <input
        name={name}
        checked={checked}
        defaultChecked={defaultChecked}
        onChange={onChange}
        value={value}
        type="radio"
      />
      <div className={`row text-radio-essential ${labelClassName}`}>
        <div className="c-radio mr-16 " />
        <div className="mr-8">{label}</div>
        {tooltip && (
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
        )}
      </div>
    </label>
  )
}
