import React, { useContext } from 'react'
import { TrackContext } from '../../TrackWelcomeModal'
import { StepButton } from './components/StepButton'
import { ButtonContainer } from './components/ButtonContainer'

export function LearningEnvironmentSelectorStep({
  onSelectLocalMachine,
  onSelectOnlineEditor,
}: Record<
  'onSelectLocalMachine' | 'onSelectOnlineEditor',
  () => void
>): JSX.Element {
  const { track } = useContext(TrackContext)
  return (
    <>
      <h3 className="text-h3 mb-8">Online or on your computer?</h3>
      <p className="mb-12">
        You can solve the exercises using either our online editor, or locally
        within your own environment. If you use your own environment,
        you&apos;ll need to install both {track.title} and the Exercism CLI.
      </p>
      <p className="mb-12">
        We generally recommend starting by using our editor.
      </p>
      <p className="mb-16">
        <span className="font-semibold">
          {' '}
          How would you like to start solving the {track.title} exercises?
        </span>
      </p>

      <div className="grid grid-cols-2 gap-12 items-center">
        <StepButton onClick={onSelectOnlineEditor} className="btn-primary">
          In the online editor
        </StepButton>
        <StepButton onClick={onSelectLocalMachine} className="btn-secondary">
          On my local machine
        </StepButton>
      </div>
    </>
  )
}
