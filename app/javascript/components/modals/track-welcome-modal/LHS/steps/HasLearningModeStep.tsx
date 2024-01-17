import React, { useContext } from 'react'
import { TrackContext } from '../../WelcomeTrackModal'
import { StepButton } from './components/StepButton'
import { ButtonContainer } from './components/ButtonContainer'
export function HasLearningModeStep({
  onSelectLearningMode,
  onSelectPracticeMode,
}: Record<
  'onSelectLearningMode' | 'onSelectPracticeMode',
  () => void
>): JSX.Element {
  const { track } = useContext(TrackContext)
  return (
    <>
      <header>
        <p>
          This track can be used for learning {track.title} (Learning Mode) or
          for practicing your existing {track.title} knowledge (Practice Mode).{' '}
          <span className="font-semibold">
            Watch this video to learn more about the difference between the
            modes 👉
          </span>
        </p>
      </header>
      <p>Would you like to use the track in learning mode or practice mode?</p>
      <ButtonContainer>
        <StepButton onClick={onSelectLearningMode}>Learning Mode</StepButton>
        <StepButton onClick={onSelectPracticeMode}>Practice Mode</StepButton>
      </ButtonContainer>
    </>
  )
}
