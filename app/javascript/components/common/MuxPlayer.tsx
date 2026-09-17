import React from 'react'
import MuxPlayerReact from '@mux/mux-player-react'
import { assembleClassNames } from '@/utils/assemble-classnames'

/**
 * A Mux-hosted video, played inline.
 *
 * This is a web component around a native <video>, not an iframe. That is
 * what lets it work on a cross-origin isolated page (the editor sends COEP
 * require-corp): a cross-origin iframe is blocked there unless the browser
 * supports the `credentialless` attribute, which Safari and Firefox do not,
 * whereas a video element just needs its fetches to be CORS. `crossOrigin`
 * makes Safari's native HLS fetches CORS too; the hls.js path used elsewhere
 * already is.
 */
export default function MuxPlayer({
  playbackId,
  title,
  className,
}: {
  playbackId: string
  title: string
  className?: string
}): JSX.Element {
  return (
    <div className={assembleClassNames('c-mux-container', className)}>
      <MuxPlayerReact
        playbackId={playbackId}
        streamType="on-demand"
        crossOrigin="anonymous"
        accentColor="#604FCD"
        metadata={{ video_title: title }}
      />
    </div>
  )
}
