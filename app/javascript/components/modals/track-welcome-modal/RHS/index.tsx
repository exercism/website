import React, { useContext, useEffect } from 'react'
import { TrackContext } from '..'
import { HasLearningModeStep } from './steps/HasLearningModeStep'
import { HasNoLearningModeStep } from './steps/HasNoLearningModeStep'
import { useMachine } from '@xstate/react'
import { StateValue, machine } from './rhs.machine'
import { useLogger } from '@/hooks'
import { LearningEnvironmentSelectorStep } from './steps/LearningEnvironmentSelectorStep'
import { SelectedLocalMachineStep } from './steps/SelectedLocalMachineStep'
import { SelectedOnlineEdiorStep } from './steps/SelectedOnlineEditorStep'

export function TrackWelcomeModalRHS(): JSX.Element {
  return (
    <div className="rhs">
      <Steps />
    </div>
  )
}

function Steps() {
  const track = useContext(TrackContext)
  const [currentStep, send] = useMachine(machine, {
    actions: {
      handleContinueToLocalMachine() {
        console.log('continue to cli hello world')
      },
      handleContinueToOnlineEditor() {
        console.log('continue to online hello world')
      },
    },
  })

  useLogger('step', currentStep)

  switch (currentStep.value as StateValue) {
    case 'hasLearningMode':
      return (
        <HasLearningModeStep
          // these should fire an action that saves preferences?
          onSelectLearningMode={() => send('SELECT_LEARNING_MODE')}
          onSelectPracticeMode={() => send('SELECT_PRACTICE_MODE')}
        />
      )
    case 'hasNoLearningMode':
      return <HasNoLearningModeStep onContinue={() => send('CONTINUE')} />

    case 'learningEnvironmentSelector':
      return (
        <LearningEnvironmentSelectorStep
          onSelectLocalMachine={() => send('SELECT_LOCAL_MACHINE')}
          onSelectOnlineEditor={() => send('SELECT_ONLINE_EDITOR')}
          onGoBack={() => send('GO_BACK')}
        />
      )

    case 'selectedLocalMachine':
      return (
        <SelectedLocalMachineStep
          onContinueToLocalMachine={() => send('CONTINUE')}
          onGoBack={() => send('GO_BACK')}
        />
      )
    case 'selectedOnlineEditor':
      return (
        <SelectedOnlineEdiorStep
          onContinueToOnlineEditor={() => send('CONTINUE')}
          onGoBack={() => send('GO_BACK')}
        />
      )

    case 'openModal':
      return (
        <OpenModal
          onHasLearningMode={() => send('HAS_LEARNING_MODE')}
          onHasNoLearningMode={() => send('HAS_NO_LEARNING_MODE')}
        />
      )
    default:
      throw new Error('No such step')
  }
}

function OpenModal({
  onHasLearningMode,
  onHasNoLearningMode,
}: Record<
  'onHasLearningMode' | 'onHasNoLearningMode',
  () => void
>): JSX.Element {
  const track = useContext(TrackContext)

  useEffect(() => {
    if (track.course) {
      onHasLearningMode()
    } else onHasNoLearningMode()
  }, [track])

  return <div>Loading..</div>
}
