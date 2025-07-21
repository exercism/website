import React from 'react'
import { TrackProgress, TrackProgressList } from '../../types'
import { TrackHeaderSpan } from '../TrackHeaderSpan'
import { TrackHeaderSummaryText } from '../TrackHeaderSummaryText'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const MAX_TRACKS = 4

export const HeaderSummary = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/learning-section'
  )
  const tracksToDisplay = tracks.sort().items.slice(0, MAX_TRACKS)

  return (
    <p>
      {t('headerSummary.youVeProgressed')}
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
