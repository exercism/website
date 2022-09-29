import React from 'react'
import { ExerciseTrackIndicator } from '.'

export function UploadVideoModalHeader({
  videoSubmitted,
}: {
  videoSubmitted: boolean
}): JSX.Element {
  return (
    <>
      <h2 className="text-h2 mb-8">Submit a community workthrough</h2>
      <p className="text-prose mb-24">
        Produced a video of working through this exercise yourself? Want to
        share it with the Exercism community?{' '}
        <strong className="font-medium text">
          Submit the form below and Jonathan (our community manager) will review
          and approve it.
        </strong>
      </p>

      <ExerciseTrackIndicator
        exercise="Amusement Park"
        exerciseIconUrl="https://dg8krxphbh767.cloudfront.net/exercises/amusement-park.svg"
        track="Rust"
        trackIconUrl="https://dg8krxphbh767.cloudfront.net/tracks/rust.svg"
        videoSubmitted={videoSubmitted}
      />
    </>
  )
}
