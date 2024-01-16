import React from 'react'
import { ExerciseTrackIndicator } from './ExerciseTrackIndicator'

export function UploadVideoModalHeader({
  videoRetrieved = false,
}: {
  videoRetrieved?: boolean
}): JSX.Element {
  return (
    <>
      <h2 className="text-h2 mb-8">Submit a community workthrough</h2>
      <p className="text-prose mb-24">
        Produced a video of working through this exercise yourself? Want to
        share it with the Exercism community?{' '}
        <strong className="font-medium text">
          Submit the form below and Jeremy will review and approve it.
        </strong>
      </p>
      <ExerciseTrackIndicator videoRetrieved={videoRetrieved} />
    </>
  )
}
