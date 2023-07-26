import React from 'react'
import { useMachine } from '@xstate/react'
import * as STEPS from './steps'
import { StateValue, machine } from './rhs.machine'
import { useLogger } from '@/hooks'
import { Choices } from './steps/components/Choices'

export function TrackWelcomeModalRHS(): JSX.Element {
  return (
    <div className="rhs">
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

  const { context } = currentState

  useLogger('context', context)
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
        <Choices context={context}>
          <STEPS.LearningEnvironmentSelectorStep
            onSelectLocalMachine={() => send('SELECT_LOCAL_MACHINE')}
            onSelectOnlineEditor={() => send('SELECT_ONLINE_EDITOR')}
            onGoBack={() => send('GO_BACK')}
          />
        </Choices>
      )

    case 'selectedLocalMachine':
      return (
        <Choices context={context}>
          <STEPS.SelectedLocalMachineStep
            onContinueToLocalMachine={() => send('CONTINUE')}
            onGoBack={() => send('GO_BACK')}
          />
        </Choices>
      )
    case 'selectedOnlineEditor':
      return (
        <Choices context={context}>
          <STEPS.SelectedOnlineEdiorStep
            onContinueToOnlineEditor={() => send('CONTINUE')}
            onGoBack={() => send('GO_BACK')}
          />
        </Choices>
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
