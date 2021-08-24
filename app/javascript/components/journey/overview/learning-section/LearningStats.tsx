import React from 'react'
import pluralize from 'pluralize'
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
        <strong>
          {tracks.numLines.toLocaleString()}{' '}
          {pluralize('line', tracks.numLines)}
        </strong>{' '}
        of code across{' '}
        <a href={links.solutions}>
          {tracks.numSolutions} {pluralize('solution', tracks.numSolutions)}
        </a>
      </div>
      <div className="stat">
        That&apos;s approximately equivalent to the length of an{' '}
        <a href={links.fable}>Aesop&apos;s Fable!</a>
      </div>
    </div>
  )
}
