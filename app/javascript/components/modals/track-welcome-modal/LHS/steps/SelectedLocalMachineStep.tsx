import React, { useContext } from 'react'
import { StepButton } from './components/StepButton'
import { ButtonContainer } from './components/ButtonContainer'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { TrackContext } from '../../WelcomeTrackModal'

export function SelectedLocalMachineStep({
  onContinueToLocalMachine,
}: Record<'onContinueToLocalMachine', () => void>): JSX.Element {
  const { track } = useContext(TrackContext)
  return (
    <>
      <h3 className="text-h3 mb-8">Let's get coding!</h3>
      <p className="mb-8">There are three steps to get started:</p>
      <ol className="list-decimal pl-16 mb-16">
        <li>
          Install{' '}
          <a href="" target="_blank">
            Exercism's CLI
          </a>
          .
        </li>
        <li>
          Install{' '}
          <a href="" target="_blank">
            {track.title}'s tooling
          </a>
          .
        </li>
        <li>
          Download this exercise:
          <div className="mr-[-54px]">
            <CopyToClipboardButton
              textToCopy={`exercism download --exercise=hello-world --track=${track.title}`}
            />
          </div>
        </li>
      </ol>

      <p className="mb-16">
        <strong className="font-semibold">All done?</strong> Click "Continue" to
        see the instructions, then solve the exercise on your machine and submit
        it via{' '}
        <code class="inline-block bg-backgroundColorD px-8 rounded-2">
          <pre>exercism submit</pre>
        </code>
        .
      </p>
      <div className="flex gap-8">
        <StepButton
          onClick={onContinueToLocalMachine}
          className="btn-primary flex-grow"
        >
          Continue
        </StepButton>
        <StepButton className="btn-secondary w-1-3">Reset choices</StepButton>
      </div>
    </>
  )
}
