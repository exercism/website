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
  const playerRef = useRef<HTMLDivElement>(null)
  const [player, setPlayer] = useState<any>(null)
  const intervalRef = useRef<NodeJS.Timeout | null>(null)

  if (!id || id.length !== 11) return null

  useEffect(() => {
    if (!window.YT) {
      const existingScript = document.querySelector(
        'script[src*="youtube.com/iframe_api"]'
      )
      if (!existingScript) {
        const tag = document.createElement('script')
        tag.src = 'https://www.youtube.com/iframe_api'
        tag.async = true
        document.head.appendChild(tag)
      }
    }

    const showVideo = () => {
      if (playerRef.current && !player && window.YT?.Player) {
        try {
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
        } catch (error) {
          console.error('Error creating YouTube player:', error)
        }
      }
    }

    intervalRef.current = setInterval(() => {
      if (window.YT?.Player) {
        showVideo()
        if (intervalRef.current) {
          clearInterval(intervalRef.current)
          intervalRef.current = null
        }
      }
    }, 100)

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current)
        intervalRef.current = null
      }
      if (player?.destroy) {
        try {
          player.destroy()
        } catch (error) {
          console.error('Error destroying YT player:', error)
        }
      }
    }
  }, [id, onPlay])

  return (
    <div className="c-youtube-container">
      <div ref={playerRef} />
    </div>
  )
}
