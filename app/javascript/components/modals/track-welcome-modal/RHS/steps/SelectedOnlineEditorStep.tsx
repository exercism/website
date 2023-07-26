import React from 'react'

export function SelectedOnlineEdiorStep({
  onContinueToOnlineEditor,
  onGoBack,
}: Record<'onGoBack' | 'onContinueToOnlineEditor', () => void>): JSX.Element {
  return (
    <>
      <p>
        Great. In that case let&apos;s jump straight into the first exercise -
        “Hello, World!
      </p>

      <button onClick={onGoBack} className="btn-primary btn-l">
        Go back
      </button>
      <button onClick={onContinueToOnlineEditor} className="btn-primary btn-l">
        Continue to online editor
      </button>
    </>
  )
}
