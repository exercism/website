import React, { useEffect, useRef, useState } from 'react'

declare global {
  interface Window {
    onYoutubeIframeAPIReady: (() => void) | null
    YT: any
  }
}

export function YoutubePlayer({
  id,
  onPlay,
}: {
  id: string
  onPlay?: () => void
}): JSX.Element | null {
  const playerRef = useRef(null)
  const [player, setPlayer] = useState<any>(null)

  useEffect(() => {
    if (!id) return

    if (!window.YT) {
      const tag = document.createElement('script')
      tag.src = 'https://www.youtube.com/iframe_api'
      const firstScriptTag = document.getElementsByTagName('script')[0]
      if (firstScriptTag.parentNode) {
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
      }
    }

    const onYoutubeIframeAPIReady = () => {
      if (playerRef.current && !player) {
        const newPlayer = new window.YT.Player(playerRef.current, {
          videoId: id,
          playerVars: {
            rel: 0,
            playsinline: 1,
          },
          events: {
            onStateChange: (event: { data: number }) => {
              if (event.data === window.YT.PlayerState.PLAYING && onPlay) {
                onPlay()
              }
            },
          },
        })
        setPlayer(newPlayer)
      }
    }

    window.onYoutubeIframeAPIReady = onYoutubeIframeAPIReady

    return () => {
      if (player && player.destroy) {
        player.destroy()
      }
    }
  }, [id, onPlay, player])

  useEffect(() => {
    if (window.YT && window.YT.Player && window.onYoutubeIframeAPIReady) {
      window.onYoutubeIframeAPIReady()
    }
  }, [id])

  return (
    <div className="c-youtube-container">
      <div ref={playerRef} />
    </div>
  )
}
