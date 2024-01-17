import React, { useContext } from 'react'
import { TrackContext } from '../../..'
import { assembleClassNames } from '@/utils/assemble-classnames'

const choiceStyle = (color: 'green' | 'yellow') =>
  `border-1 border-${color}Prompt text-textColor1 bg-${color}Prompt bg-opacity-40 font-semibold`

const unsetStyle = choiceStyle('yellow')
const setStyle = choiceStyle('green')

export function Choices(): JSX.Element {
  const { choices } = useContext(TrackContext)

  return (
    <div className="flex gap-8">
      {Object.entries(choices).map(([key, value], id) => (
        <span
          className={assembleClassNames(
            'py-6 px-12 rounded-24',
            value === 'Unset' ? unsetStyle : setStyle
          )}
          key={id}
        >
          {key}: {value}
        </span>
      ))}
    </div>
  )
}
