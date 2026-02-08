import React, { useEffect, useRef } from 'react'

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
  const playerInstanceRef = useRef<any>(null)
  const intervalRef = useRef<NodeJS.Timeout | null>(null)
  const isMountedRef = useRef(true)
  const playerCreatedRef = useRef(false)

  useEffect(() => {
    if (!id || id.length !== 11) return

    isMountedRef.current = true
    playerCreatedRef.current = false

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
      if (!isMountedRef.current) return
      if (playerCreatedRef.current) return
      if (!playerRef.current) return
      if (!window.YT?.Player) return

      playerCreatedRef.current = true

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
        playerInstanceRef.current = newPlayer
      } catch (error) {
        playerCreatedRef.current = false
        console.error('Error creating YouTube player:', error)
      }
    }

    intervalRef.current = setInterval(() => {
      if (window.YT?.Player) {
        if (intervalRef.current) {
          clearInterval(intervalRef.current)
          intervalRef.current = null
        }
        showVideo()
      }
    }, 100)

    return () => {
      isMountedRef.current = false

      if (intervalRef.current) {
        clearInterval(intervalRef.current)
        intervalRef.current = null
      }

      if (playerInstanceRef.current?.destroy) {
        try {
          playerInstanceRef.current.destroy()
        } catch (error) {
          console.error('Error destroying YT player:', error)
        }
      }
      playerInstanceRef.current = null
      playerCreatedRef.current = false
    }
  }, [id, onPlay])

  if (!id || id.length !== 11) return null

  return (
    <div className="c-youtube-container">
      <div ref={playerRef} />
    </div>
  )
}
