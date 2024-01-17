import React, { useContext } from 'react'
import { TrackContext } from '../../..'
import { assembleClassNames } from '@/utils/assemble-classnames'

const unsetStyle = `border-1 border-yellowPrompt text-textColor1 bg-yellowPrompt bg-opacity-40 font-semibold`
const setStyle = `border-1 border-greenPrompt text-textColor1 bg-greenPrompt bg-opacity-40 font-semibold`

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
