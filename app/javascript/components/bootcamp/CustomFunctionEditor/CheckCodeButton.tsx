import React from 'react'

export function CheckCodeButton({
  handleRunCode,
}: {
  handleRunCode: () => void
}) {
  return (
    <button
      onClick={handleRunCode}
      className="scenarios-button flex btn-primary btn-xs"
    >
      Check code
    </button>
  )
}
