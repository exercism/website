import React, { useContext, useEffect } from 'react'
import { TrackContext } from '../../TrackWelcomeModal'

export function OpenModalStep({
  onHasLearningMode,
  onHasNoLearningMode,
}: Record<
  'onHasLearningMode' | 'onHasNoLearningMode',
  () => void
>): JSX.Element {
  const { track } = useContext(TrackContext)

  useEffect(() => {
    if (track.course) {
      onHasLearningMode()
    } else onHasNoLearningMode()
  }, [onHasLearningMode, onHasNoLearningMode, track])

  return <div>Loading..</div>
}
