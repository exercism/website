import React, { useContext } from 'react'
import { TrackContext } from '../../TrackWelcomeModal'
import { StepButton } from './components/StepButton'
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
      <h3 className="text-h3 mb-8">Here to learn or practice?</h3>
      <p className="mb-12">
        This track can be used for learning {track.title} (Learning Mode) or for
        practicing your existing {track.title} knowledge (Practice Mode).{' '}
      </p>
      <p className="mb-12">
        We recommend Learning Mode if you're new to {track.title}, and Practice
        Mode if you're experienced.
      </p>
      <p className="mb-16">
        <span className="font-semibold">
          Would you like to start the track in Learning Mode or Practice Mode?
        </span>{' '}
        (You can always change later.)
      </p>

      <div className="grid grid-cols-2 gap-12 items-center">
        <StepButton onClick={onSelectLearningMode} className="btn-primary">
          Learning Mode
        </StepButton>
        <StepButton onClick={onSelectPracticeMode} className="btn-secondary">
          Practice Mode
        </StepButton>
      </div>
    </>
  )
}
