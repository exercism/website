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
      document.head.append(tag, firstScriptTag)
    }

    const showVideo = () => {
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

    const ytChecker = setInterval(() => {
      if (!window.YT) return
      if (!window.YT.loaded) return

      showVideo()
      clearInterval(ytChecker)
    }, 10)

    return () => {
      if (player && player.destroy) {
        player.destroy()
      }
      clearInterval(ytChecker)
    }
  }, [id, onPlay, player])

  return (
    <div className="c-youtube-container">
      <div ref={playerRef} />
    </div>
  )
}
