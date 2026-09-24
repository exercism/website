import React from 'react'
import { Trans } from 'react-i18next'

const NAMESPACE = 'components/journey/overview/TrackHeaderSummaryText.tsx'

/**
 * One key per list length rather than a joiner between spans: the separators
 * and their order are part of the sentence, so they have to be translatable
 * alongside it.
 */
export const TrackHeaderSummaryText = <T extends unknown>({
  tracks,
  SpanComponent,
}: {
  tracks: readonly T[]
  SpanComponent: React.ComponentType<{ track: T }>
}): JSX.Element | null => {
  if (tracks.length < 1 || tracks.length > 4) return null

  return (
    <Trans
      ns={NAMESPACE}
      i18nKey={`trackList.${tracks.length}`}
      components={tracks.map((track, i) => (
        <SpanComponent key={i} track={track} />
      ))}
    />
  )
}
