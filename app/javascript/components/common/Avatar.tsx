import React from 'react'

export const Avatar = ({
  src,
  handle,
  className = '',
}: {
  src: string
  handle?: string
  className?: string
}): JSX.Element => {
  const alt = handle ? `Uploaded avatar of ${handle}` : ''
  return (
    <div
      className={`c-avatar ${className}`}
      style={{ backgroundImage: `url(${src})` }}
    >
      <img src={src} alt={alt} className="sr-only" />
    </div>
  )
}
