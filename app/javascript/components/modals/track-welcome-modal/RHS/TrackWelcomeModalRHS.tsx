import React, { useContext } from 'react'
import { TrackContext } from '../TrackWelcomeModal'
import { VideoRHS } from './VideoRHS'
import { WhoIsThisTrackForRHS } from './WhoIsThisTrackForRHS'

export function TrackWelcomeModalRHS(): JSX.Element {
  const { track, currentState, shouldShowBootcampRecommendationView } =
    useContext(TrackContext)

  if (
    currentState.matches('learningEnvironmentSelector') &&
    shouldShowBootcampRecommendationView
  ) {
    return <WhoIsThisTrackForRHS />
  }

  return <VideoRHS track={track} />
}
