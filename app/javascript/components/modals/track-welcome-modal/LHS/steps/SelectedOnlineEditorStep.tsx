import React from 'react'
import { StepButton } from './components/StepButton'

export function SelectedOnlineEdiorStep({
  onContinueToOnlineEditor,
}: Record<'onContinueToOnlineEditor', () => void>): JSX.Element {
  return (
    <>
      <h3 className="text-h3 mb-8">You're all set!</h3>
      <p className="mb-16">
        If you change your mind later and want to work in our own environment,
        you'll find instructions for installing the Exercism CLI and language
        tooling on the right-hand side of each exercise.
      </p>
      <p className="mb-16">
        Let&apos;s jump straight into the first exercise, "Hello, World!", which
        will ensure you're comfortable with the editor.
      </p>

      <div className="flex gap-8">
        <StepButton
          onClick={onContinueToOnlineEditor}
          className="btn-primary flex-grow"
        >
          Continue to online editor
        </StepButton>
        <StepButton className="btn-secondary w-1-3">Reset choices</StepButton>
      </div>
    </>
  )
}
