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
    : currentState.value !== 'hasNoLearningMode' &&
      currentState.value !== 'learningEnvironmentSelector'
  return (
    <div className="flex flex-col items-center gap-16 mt-24 mx-[-48px] mb-[-40px] px-48 py-20 bg-backgroundColorD border-borderColor7">
      <div className="flex gap-8 ">
        {Object.entries(currentState.context.choices).map(
          ([key, value], id) => (
            <span
              className={assembleClassNames(
                'py-6 px-12 rounded-24 flex items-center',
                value === 'Unset' ? unsetStyle : setStyle
              )}
              key={id}
            >
              {key}: {value}
            </span>
          )
        )}
      </div>
      {showResetButton && (
        <button
          className="flex items-center gap-4"
          onClick={() => send('RESET')}
        >
          <Icon
            icon="reset"
            alt="reset-button"
            height={16}
            width={16}
            className="filter-textColor6"
          />
          <span className="font-medium">Reset Choices</span>
        </button>
      )}
    </div>
  )
}
