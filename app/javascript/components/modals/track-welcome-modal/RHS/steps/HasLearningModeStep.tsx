import React, { useContext } from 'react'
import { TrackContext } from '../..'
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
        <h1 className="text-h1">Welcome to {track.title}! 💙</h1>

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
        <button onClick={onSelectLearningMode} className="btn-primary btn-l">
          Learning Mode
        </button>
        <button onClick={onSelectPracticeMode} className="btn-primary btn-l">
          Practice Mode
        </button>
      </div>
    </>
  )
}
