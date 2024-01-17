import React from 'react'
import { StepButton } from './components/StepButton'
import { ButtonContainer } from './components/ButtonContainer'

export function SelectedLocalMachineStep({
  onContinueToLocalMachine,
  onReset,
}: Record<'onReset' | 'onContinueToLocalMachine', () => void>): JSX.Element {
  return (
    <>
      <header>
        <p>
          I&apos;ll write the text out later including a link to the CLI
          walkthrough, and the copy-to-clipboard widget for Hello World. If you
          get those links in, I&apos;ll do the rest.
        </p>
      </header>
      <ButtonContainer>
        <StepButton onClick={onReset}>Reset</StepButton>
        <StepButton onClick={onContinueToLocalMachine}>Continue</StepButton>
      </ButtonContainer>
    </>
  )
}
