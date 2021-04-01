import React from 'react'

export const Avatar = ({
  src,
  handle,
  className,
}: {
  src: string
  handle: string
  className?: string
}): JSX.Element => (
  <div
    className={`c-avatar ${className}`}
    style={{ backgroundImage: `url(${src})` }}
  >
    <img
      src={src}
      alt={`Uploaded avatar of ${handle}`}
      className="tw-sr-only"
    />
  </div>
)
