import React from 'react'

export function SelectedLocalMachineStep({
  onContinueToLocalMachine,
  onGoBack,
}: Record<'onGoBack' | 'onContinueToLocalMachine', () => void>): JSX.Element {
  return (
    <>
      <p>
        I&apos;ll write the text out later including a link to the CLI
        walkthrough, and the copy-to-clipboard widget for Hello World. If you
        get those links in, I&apos;ll do the rest.
      </p>

      <button onClick={onGoBack} className="btn-primary btn-l">
        Go back
      </button>
      <button onClick={onContinueToLocalMachine} className="btn-primary btn-l">
        Continue
      </button>
    </>
  )
}
