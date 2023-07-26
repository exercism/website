import React from 'react'
import { StepButton } from './components/StepButton'

export function SelectedLocalMachineStep({
  onContinueToLocalMachine,
  onGoBack,
}: Record<'onGoBack' | 'onContinueToLocalMachine', () => void>): JSX.Element {
  return (
    <>
      <header>
        <p>
          I&apos;ll write the text out later including a link to the CLI
          walkthrough, and the copy-to-clipboard widget for Hello World. If you
          get those links in, I&apos;ll do the rest.
        </p>
      </header>
      <div className="flex gap-12 items-center">
        <StepButton onClick={onGoBack}>Go back</StepButton>
        <StepButton onClick={onContinueToLocalMachine}>Continue</StepButton>
      </div>
    </>
  )
}
