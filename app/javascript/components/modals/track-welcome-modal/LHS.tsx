import React from 'react'

export function TrackWelcomeModalLHS(): JSX.Element {
  return (
    <div className="lhs">
      <div
        className="video relative rounded-8 overflow-hidden !mb-24"
        style={{ padding: '56.25% 0 0 0', position: 'relative' }}
      >
        <iframe
          src="https://www.youtube-nocookie.com/embed/zomfphsDQrs"
          title="Welcome to Exercism Insiders!"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        />
      </div>
    </div>
  )
}
