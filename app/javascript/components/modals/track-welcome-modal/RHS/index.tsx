import React, { useContext, useEffect } from 'react'
import { TrackContext } from '..'
import { HasLearningModeStep } from './steps/HasLearningModeStep'
import { HasNoLearningModeStep } from './steps/HasNoLearningModeStep'
import { useMachine } from '@xstate/react'
import { machine } from './rhs.machine'
import { useLogger } from '@/hooks'

export function TrackWelcomeModalRHS(): JSX.Element {
  const track = useContext(TrackContext)
  return (
    <div className="rhs">
      <header>
        <h1 className="text-h1">Welcome to {track.title}! 💙</h1>

        <Steps />
      </header>
    </div>
  )
}

function Steps() {
  const track = useContext(TrackContext)
  const [currentStep, send] = useMachine(machine, {
    actions: {
      handleContinueToCli() {
        console.log('continue to cli')
      },
      handleContinueToLocal() {
        console.log('continue to local')
      },
    },
  })

  useLogger('step', currentStep)

  useEffect(() => {
    if (track.course) {
      send('HAS_LEARNING_MODE')
    } else send('HAS_NO_LEARNING_MODE')
  }, [send, track])

  switch (currentStep.value) {
    case 'hasLearningMode':
      return <HasLearningModeStep />
    case 'hasNoLearningMode':
      return <HasNoLearningModeStep />
    default:
      return <div>Loading..</div>
  }
}
