import React from 'react'

/**
 * @param animationDuration in seconds
 */
export function LoadingBar({
  animationDuration,
}: {
  animationDuration: number
}): JSX.Element {
  return (
    <div className="c-loading-bar">
      <div
        className="bar"
        style={{
          animationDuration: `${animationDuration}s`,
        }}
      />
    </div>
  )
}
