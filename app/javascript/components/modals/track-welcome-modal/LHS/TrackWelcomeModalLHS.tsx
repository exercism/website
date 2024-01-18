import React, { useContext } from 'react'
import * as STEPS from './steps'
import { StateValue } from './TrackWelcomeModal.machine'
import { WelcomeToTrack } from './steps/components/WelcomeToTrack'
import { TrackContext } from '../TrackWelcomeModal'

export function TrackWelcomeModalLHS(): JSX.Element {
  return (
    <div className="lhs">
      <WelcomeToTrack />
      <Steps />
    </div>
  )
}

function Steps() {
  const { send, currentState } = useContext(TrackContext)

  switch (currentState.value as StateValue) {
    case 'hasLearningMode':
      return (
        <STEPS.HasLearningModeStep
          onSelectLearningMode={() => send('SELECT_LEARNING_MODE')}
          onSelectPracticeMode={() => send('SELECT_PRACTICE_MODE')}
        />
      )
    case 'hasNoLearningMode':
      return <STEPS.HasNoLearningModeStep onContinue={() => send('CONTINUE')} />

    case 'learningEnvironmentSelector':
      return (
        <STEPS.LearningEnvironmentSelectorStep
          onSelectLocalMachine={() => send('SELECT_LOCAL_MACHINE')}
          onSelectOnlineEditor={() => send('SELECT_ONLINE_EDITOR')}
        />
      )

    case 'selectedLocalMachine':
      return (
        <STEPS.SelectedLocalMachineStep
          onContinueToLocalMachine={() => send('CONTINUE')}
        />
      )
    case 'selectedOnlineEditor':
      return (
        <STEPS.SelectedOnlineEdiorStep
          onContinueToOnlineEditor={() => send('CONTINUE')}
        />
      )

    default:
      return (
        <STEPS.OpenModalStep
          onHasLearningMode={() => send('HAS_LEARNING_MODE')}
          onHasNoLearningMode={() => send('HAS_NO_LEARNING_MODE')}
        />
      )
  }
}
