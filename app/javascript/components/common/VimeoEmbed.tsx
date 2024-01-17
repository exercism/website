import React from 'react'

export default function VimeoEmbed({ id }) {
  const src = `https://player.vimeo.com/video/${id}&badge=0&autopause=0&player_id=0&app_id=58479&transparent=0`

  return (
    <div className="c-vimeo-container">
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
