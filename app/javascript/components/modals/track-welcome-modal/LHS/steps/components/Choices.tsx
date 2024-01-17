import React, { useContext } from 'react'
import { TrackContext } from '../../../WelcomeTrackModal'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { Icon } from '@/components/common/Icon'

const unsetStyle = `border-1 border-yellowPrompt text-textColor1 bg-yellowPrompt bg-opacity-40 font-semibold`
const setStyle = `border-1 border-greenPrompt text-textColor1 bg-greenPrompt bg-opacity-40 font-semibold`

export function Choices(): JSX.Element {
  const { currentState, send, track } = useContext(TrackContext)

  const showResetButton = track.course
    ? currentState.value !== 'hasLearningMode'
    : currentState.value !== 'hasNoLearningMode' ||
      currentState.value !== 'learningEnvironmentSelector'

  return (
    <div className="flex gap-8">
      {Object.entries(currentState.context.choices).map(([key, value], id) => (
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

      {showResetButton && (
        <button onClick={() => send('RESET')}>
          <Icon
            icon="reset"
            alt="reset-button"
            height={16}
            width={16}
            className="filter-textColor6"
          />
        </button>
      )}
    </div>
  )
}
