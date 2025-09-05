import React from 'react'
import { TrackContribution } from '../../../types'
import { TrackHeaderSummaryText } from '../TrackHeaderSummaryText'
import { TrackHeaderSpan } from '../TrackHeaderSpan'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const MAX_TRACKS = 4

class TrackContributionWithPercentage {
  track: TrackContribution
  totalReputation: number

  get percentage(): number {
    return (100 * this.track.totalReputation) / this.totalReputation
  }

  get slug(): string | null {
    return this.track.slug
  }

  get title(): string {
    return this.track.title
  }

  constructor(track: TrackContribution, totalReputation: number) {
    this.track = track
    this.totalReputation = totalReputation
  }
}

export const HeaderSummary = ({
  tracks,
}: {
  tracks: readonly TrackContribution[]
}): JSX.Element => {
  const { t } = useAppTranslation()
  const allTrack = tracks.find((track) => track.slug === null)

  if (!allTrack) {
    throw new Error('Incomplete track data')
  }

  const tracksToDisplay = tracks
    .filter((track) => track !== allTrack)
    .sort((a, b) => (a.totalReputation < b.totalReputation ? 1 : -1))
    .slice(0, MAX_TRACKS)
    .map(
      (track) =>
        new TrackContributionWithPercentage(track, allTrack.totalReputation)
    )

  return (
    <p>
      {t('headerSummary.youHaveContributedMostTo')}{' '}
      <TrackHeaderSummaryText<TrackContributionWithPercentage>
        tracks={tracksToDisplay}
        SpanComponent={TrackSummary}
      />
    </p>
  )
}

const TrackSummary = ({
  track,
}: {
  track: TrackContributionWithPercentage
}): JSX.Element => {
  const { t } = useAppTranslation()
  if (!track.slug) {
    throw new Error(t('headerSummary.noSummaryForTrack'))
  }

  return (
    <TrackHeaderSpan slug={track.slug}>
      {track.title} ({track.percentage.toFixed(2)}%)
    </TrackHeaderSpan>
  )
}
