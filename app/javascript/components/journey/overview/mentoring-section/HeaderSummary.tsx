// i18n-key-prefix: headerSummary
// i18n-namespace: components/journey/overview/mentoring-section
import React from 'react'
import { MentoredTrackProgress, MentoredTrackProgressList } from '../../types'
import { TrackHeaderSpan } from '../TrackHeaderSpan'
import { TrackHeaderSummaryText } from '../TrackHeaderSummaryText'
import { useAppTranslation } from '@/i18n/useAppTranslation'

class MentoredTrackProgressWithPercentage {
  track: MentoredTrackProgress
  numTotalSessions: number

  get percentage(): number {
    return (100 * this.track.numDiscussions) / this.numTotalSessions
  }

  get slug(): string {
    return this.track.slug
  }

  get title(): string {
    return this.track.title
  }

  constructor(track: MentoredTrackProgress, numTotalSessions: number) {
    this.track = track
    this.numTotalSessions = numTotalSessions
  }
}

const MAX_TRACKS = 4

export const HeaderSummary = ({
  tracks,
}: {
  tracks: MentoredTrackProgressList
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/mentoring-section'
  )
  const tracksToDisplay = tracks
    .sort()
    .items.slice(0, MAX_TRACKS)
    .map(
      (track) =>
        new MentoredTrackProgressWithPercentage(
          track,
          tracks.totals.discussions
        )
    )

  return (
    <p>
      {t('headerSummary.youVeMostlyMentoredIn')}{' '}
      <TrackHeaderSummaryText<MentoredTrackProgressWithPercentage>
        tracks={tracksToDisplay}
        SpanComponent={TrackSummary}
      />
    </p>
  )
}

const TrackSummary = ({
  track,
}: {
  track: MentoredTrackProgressWithPercentage
}): JSX.Element => {
  return (
    <TrackHeaderSpan slug={track.slug}>
      {track.title} ({track.percentage.toFixed(2)}%)
    </TrackHeaderSpan>
  )
}
