import React, { useEffect, useRef } from 'react'

declare global {
  interface Window {
    onYouTubeIframeAPIReady: (() => void) | null
    YT: any
  }
}

export function YouTubePlayer({
  id,
  onPlay,
}: {
  id: string
  onPlay?: () => void
}): JSX.Element {
  const playerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const handleStateChange = (event: { data: number }) => {
      if (event.data === window.YT.PlayerState.PLAYING) {
        onPlay
      }
    }

    window.onYouTubeIframeAPIReady = () => {
      new window.YT.Player(playerRef.current, {
        height: '315',
        width: '560',
        videoId: id,
        playerVars: {
          playsinline: 1,
        },
        events: {
          onStateChange: handleStateChange,
        },
      })
    }

    const tag = document.createElement('script')
    tag.src = 'https://www.youtube.com/iframe_api'
    const firstScriptTag = document.getElementsByTagName('script')[0]
    firstScriptTag.parentNode?.insertBefore(tag, firstScriptTag)

    return () => {
      const iframeApiScript = document.querySelector(
        'script[src="https://www.youtube.com/iframe_api"]'
      )
      if (iframeApiScript) {
        iframeApiScript.remove()
      }
      window.onYouTubeIframeAPIReady = null
    }
  }, [])

  return (
    <div className="c-youtube-container">
      <div ref={playerRef} />
    </div>
  )
}
