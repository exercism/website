import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'

export default function VimeoEmbed({
  id,
  className,
}: {
  id: string
  className?: string
}) {
  const src = `https://player.vimeo.com/video/${id}&badge=0&autopause=0&player_id=0&app_id=58479&transparent=0`

  return (
    <div className={assembleClassNames('c-vimeo-container', className)}>
      <iframe
        width="560"
        height="315"
        src={src}
        frameBorder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
      />
      <script src="https://player.vimeo.com/api/player.js"></script>
    </div>
  )
}
