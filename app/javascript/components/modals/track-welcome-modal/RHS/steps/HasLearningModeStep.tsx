import React, { useContext } from 'react'
import { TrackContext } from '../..'
import { WelcomeToTrack } from './components/WelcomeToTrack'
import { StepButton } from './components/StepButton'
export function HasLearningModeStep({
  onSelectLearningMode,
  onSelectPracticeMode,
}: Record<
  'onSelectLearningMode' | 'onSelectPracticeMode',
  () => void
>): JSX.Element {
  const track = useContext(TrackContext)
  return (
    <>
      <header>
        <WelcomeToTrack />
        <p>
          This track can be used for learning {track.title} or for practicing
          your existing {track.title} knowledge. Our {track.title} syllabus
          teaches&nbsp;
          {track.numConcepts} different {track.title}&nbsp; concepts, and we
          have {track.numExercises} exercises to practice on.
        </p>
        <p>
          Would you like to use the track in learning mode or practice mode?
        </p>
      </header>
      <div className="flex gap-12 items-center">
        <StepButton onClick={onSelectLearningMode}>Learning Mode</StepButton>
        <StepButton onClick={onSelectPracticeMode}>Practice Mode</StepButton>
      </div>
    </>
  )
}
