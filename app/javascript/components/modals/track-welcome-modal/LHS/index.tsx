import React, { useContext, useEffect } from 'react'
import { useMachine } from '@xstate/react'
import * as STEPS from './steps'
import { StateValue, machine } from './lhs.machine'
import { useLogger } from '@/hooks'
import { WelcomeToTrack } from './steps/components/WelcomeToTrack'
import { TrackContext } from '..'

export function TrackWelcomeModalLHS(): JSX.Element {
  return (
    <div className="lhs">
      <WelcomeToTrack />
      <Steps />
    </div>
  )
}

function Steps() {
  const [currentState, send] = useMachine(machine, {
    actions: {
      handleContinueToLocalMachine() {
        console.log('continue to cli hello world')
      },
      handleContinueToOnlineEditor() {
        console.log('continue to online hello world')
      },
    },
  })

  const { setChoices } = useContext(TrackContext)

  const { context } = currentState

  useEffect(() => {
    setChoices(context.choices)
  }, [context.choices])

  switch (currentState.value as StateValue) {
    case 'hasLearningMode':
      return (
        <STEPS.HasLearningModeStep
          // these should fire an action that saves preferences?
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
          onGoBack={() => send('RESET')}
        />
      )

    case 'selectedLocalMachine':
      return (
        <STEPS.SelectedLocalMachineStep
          onContinueToLocalMachine={() => send('CONTINUE')}
          onGoBack={() => send('RESET')}
        />
      )
    case 'selectedOnlineEditor':
      return (
        <STEPS.SelectedOnlineEdiorStep
          onContinueToOnlineEditor={() => send('CONTINUE')}
          onGoBack={() => send('RESET')}
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
