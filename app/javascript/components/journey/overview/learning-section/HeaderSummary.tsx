import React from 'react'
import { TrackProgress, TrackProgressList } from '../../types'
import { TrackHeaderSpan } from '../TrackHeaderSpan'
import { TrackHeaderSummaryText } from '../TrackHeaderSummaryText'

const MAX_TRACKS = 4

export const HeaderSummary = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  const tracksToDisplay = tracks.sort().items.slice(0, MAX_TRACKS)

  return (
    <p>
      You&apos;ve progressed the furthest in{' '}
      <TrackHeaderSummaryText<TrackProgress>
        tracks={tracksToDisplay}
        SpanComponent={TrackSummary}
      />
    </p>
  )
}

const TrackSummary = ({ track }: { track: TrackProgress }): JSX.Element => {
  return (
    <TrackHeaderSpan slug={track.slug}>
      {track.title} ({track.completion.toFixed(2)}%)
    </TrackHeaderSpan>
  )
}
