// Stands in for @mux/mux-player-react under Jest. The real player is a web
// component around a <video> and pulls in @mux/mux-video, whose package
// `exports` map Jest 27 cannot resolve; jsdom could not play it anyway.
import React from 'react'

export default function MuxPlayerMock(props: {
  playbackId: string
  poster?: string
}): JSX.Element {
  return <div data-testid="mux-player" data-playback-id={props.playbackId} />
}
