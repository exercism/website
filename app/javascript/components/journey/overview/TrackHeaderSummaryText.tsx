import React from 'react'

export const TrackHeaderSummaryText = <T extends unknown>({
  tracks,
  SpanComponent,
}: {
  tracks: readonly T[]
  SpanComponent: React.ComponentType<{ track: T }>
}): JSX.Element | null => {
  switch (tracks.length) {
    case 4:
      return (
        <React.Fragment>
          <SpanComponent track={tracks[0]} />
          {', '} followed by <SpanComponent track={tracks[1]} />
          {', '}
          <SpanComponent track={tracks[2]} />
          {' and '}
          <SpanComponent track={tracks[3]} />.
        </React.Fragment>
      )
    case 3:
      return (
        <React.Fragment>
          <SpanComponent track={tracks[0]} />
          {', '} followed by <SpanComponent track={tracks[1]} />
          {' and '}
          <SpanComponent track={tracks[2]} />.
        </React.Fragment>
      )
    case 2:
      return (
        <React.Fragment>
          <SpanComponent track={tracks[0]} /> followed by{' '}
          <SpanComponent track={tracks[1]} />.
        </React.Fragment>
      )
    case 1:
      return (
        <React.Fragment>
          <SpanComponent track={tracks[0]} />.
        </React.Fragment>
      )
    default:
      return null
  }
}
