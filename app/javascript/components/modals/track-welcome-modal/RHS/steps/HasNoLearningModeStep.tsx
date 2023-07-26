import React, { useContext } from 'react'
import { TrackContext } from '../..'
export function HasNoLearningModeStep(): JSX.Element {
  const track = useContext(TrackContext)
  return (
    <>
      <p>
        Welcome to the {track.title} Track. This track is designed to help you
        practicing {track.title} through. a series of&nbsp;
        {track.numExercises} exercises. Unlike some tracks,&nbsp;
        {track.title} doesn&apos;t contain a learning mode, so if you&apos;d
        like to learn the language, we also recommend some suplimentary
        resources, which we&apos;ve listed&nbsp;
        <a href="learning_doc path">here</a>.
      </p>
      <button className="btn-primary btn-l">Continue</button>
    </>
  )
}
