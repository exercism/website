import React, { useContext } from 'react'
import { TrackContext } from '../..'
import { StepButton } from './components/StepButton'

export function LearningEnvironmentSelectorStep({
  onSelectLocalMachine,
  onSelectOnlineEditor,
  onGoBack,
}: Record<
  'onSelectLocalMachine' | 'onSelectOnlineEditor' | 'onGoBack',
  () => void
>): JSX.Element {
  const track = useContext(TrackContext)
  return (
    <>
      <header>
        <h1 className="text-h1">Welcome to {track.title}! 💙</h1>
        <p>
          You can solve the exercises on our {track.title} track either within
          our online editor, or locally within your own environment. If you use
          your own environment, you&apos;ll need to install both {track.title}{' '}
          and the Exercism CLI. How would you like to solve the Prolog
          exercises.
        </p>
      </header>
      <p>Would you like to use the track in learning mode or practice mode?</p>

      <div className="flex gap-12 items-center">
        <StepButton onClick={onGoBack}>Go back</StepButton>
        <StepButton onClick={onSelectOnlineEditor}>
          In the online editor
        </StepButton>
        <StepButton onClick={onSelectLocalMachine}>
          On my local machine
        </StepButton>
      </div>
    </>
  )
}
