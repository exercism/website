import React from 'react'
import { TrackProgressList } from '../../types'

type Links = {
  solutions: string
  fable: string
}

export const LearningStats = ({
  tracks,
  links,
}: {
  tracks: TrackProgressList
  links: Links
}): JSX.Element => {
  return (
    <div className="stats">
      <h3>Did you know?</h3>
      <div className="stat">
        You&apos;ve written{' '}
        <strong>{tracks.numLines.toLocaleString()} lines</strong> of code across{' '}
        <a href={links.solutions}>{tracks.numSolutions} solutions</a>
      </div>
      <div className="stat">
        That&apos;s approximately equivalent to the length of an{' '}
        <a href={links.fable}>Aesop&apos;s Fable!</a>
      </div>
    </div>
  )
}
