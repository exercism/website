import React, { useContext } from 'react'
import { TrackContext } from '../..'
export function HasNoLearningModeStep({
  onContinue,
}: {
  onContinue: () => void
}): JSX.Element {
  const track = useContext(TrackContext)
  return (
    <>
      <header>
        <h1 className="text-h1">Welcome to {track.title}! 💙</h1>
        <p>
          Welcome to the {track.title} Track. This track is designed to help you
          practicing {track.title} through. a series of&nbsp;
          {track.numExercises} exercises. Unlike some tracks,&nbsp;
          {track.title} doesn&apos;t contain a learning mode, so if you&apos;d
          like to learn the language, we also recommend some suplimentary
          resources, which we&apos;ve listed&nbsp;
          <a href="learning_doc path">here</a>.
        </p>
      </header>
      <button onClick={onContinue} className="btn-primary btn-l">
        Continue
      </button>
    </>
  )
}
