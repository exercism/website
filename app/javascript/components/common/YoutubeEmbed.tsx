import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export default function YoutubeEmbed({
  id,
  className,
}: {
  id: string
  className?: string
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
      />
      <script src="https://player.vimeo.com/api/player.js"></script>
    </div>
  )
}
