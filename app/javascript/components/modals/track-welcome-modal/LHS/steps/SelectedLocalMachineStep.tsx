import React, { useContext } from 'react'
import { StepButton } from './components/StepButton'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { TrackContext } from '../../TrackWelcomeModal'

export function SelectedLocalMachineStep({
  onContinueToLocalMachine,
}: Record<'onContinueToLocalMachine', () => void>): JSX.Element {
  const { track, send, links } = useContext(TrackContext)
  return (
    <>
      <h3 className="text-h3 mb-8">Let's get coding!</h3>
      <p className="mb-8">There are three steps to get started:</p>
      <ol className="list-decimal pl-16 mb-16">
        <li>
          Install{' '}
          <a
            href={links.cliWalkthrough}
            target="_blank"
            rel="noopener noreferrer"
          >
            Exercism's CLI
          </a>
          .
        </li>
        <li>
          Install{' '}
          <a
            href={links.trackTooling}
            target="_blank"
            rel="noopener noreferrer"
          >
            {track.title}'s tooling
          </a>
          .
        </li>
        <li>
          Download this exercise:
          <CopyToClipboardButton textToCopy={links.downloadCmd} />
        </li>
      </ol>

      <div className="text-17 leading-huge mb-16">
        <strong className="font-semibold">All done?</strong> Click "Continue" to
        see the instructions, then solve the exercise on your machine and submit
        it via{' '}
        <code className="inline-block bg-backgroundColorD px-8 rounded-2">
          <pre>exercism submit</pre>
        </code>
        .
      </div>
      <div className="flex gap-8">
        <StepButton
          onClick={onContinueToLocalMachine}
          className="btn-primary flex-grow"
        >
          Continue
        </StepButton>
        <StepButton
          onClick={() => send('RESET')}
          className="btn-secondary w-1-3"
        >
          Reset choices
        </StepButton>
      </div>
    </>
  )
}
