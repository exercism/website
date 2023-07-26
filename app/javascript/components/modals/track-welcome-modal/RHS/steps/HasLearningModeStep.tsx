import React, { useContext } from 'react'
import { TrackContext } from '../..'
export function HasLearningModeStep(): JSX.Element {
  const track = useContext(TrackContext)
  return (
    <>
      <p>
        This track can be used for learning {track.title} or for practicing your
        existing {track.title} knowledge. Our {track.title} syllabus
        teaches&nbsp;
        {track.numConcepts} different {track.title}&nbsp; concepts, and we have{' '}
        {track.numExercises} exercises to practice on.
      </p>
      <p>Would you like to use the track in learning mode or practice mode?</p>
      <div className="flex gap-12 items-center">
        <button className="btn-primary btn-l">Learning Mode</button>
        <button className="btn-primary btn-l">Practice Mode</button>
      </div>
    </>
  )
}
