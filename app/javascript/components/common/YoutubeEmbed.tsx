import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export default function YoutubeEmbed({
  id,
  className,
  onPlay,
}: {
  id: string
  className?: string
  onPlay?: () => void
}) {
  const src = `https://www.youtube-nocookie.com/embed/${id}`

  return (
    <div className={assembleClassNames('c-youtube-container', className)}>
      <iframe
        width="560"
        height="315"
        src={src}
        frameBorder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
        title="YouTube video player"
        onPlay={onPlay}
      />
    </div>
  )
}
