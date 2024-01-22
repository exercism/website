import React, { useContext } from 'react'
import { TrackContext } from '../../TrackWelcomeModal'
import { StepButton } from './components/StepButton'
export function HasNoLearningModeStep({
  onContinue,
}: {
  onContinue: () => void
}): JSX.Element {
  const { track, links } = useContext(TrackContext)
  return (
    <>
      <h3 className="text-h3 mb-8">You'll be in Practice Mode</h3>
      <p className="mb-12">
        The {track.title} track is designed to help you practice the language.
        Unlike some tracks,&nbsp;
        {track.title} doesn&apos;t have a Learning Mode yet, so you'll be
        completing the track's {track.numExercises} exercises in Practice Mode.
      </p>
      <p className="mb-12">
        {' '}
        If you&apos;d like to learn {track.title} from scratch, take a look at
        these{' '}
        <a
          className="font-semibold text-prominentLinkColor"
          href={links.learningResources}
          target="_blank"
          rel="noopener noreferrer"
        >
          these supplementary resources
        </a>{' '}
        that we've collated for you.
      </p>
      <StepButton onClick={onContinue} className="btn-primary w-fit">
        Continue
      </StepButton>
    </>
  )
}
