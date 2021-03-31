import React from 'react'
import { CopyToClipboardButton } from '../common'
import { ComboButton } from '../common/ComboButton'
import { StartExerciseButton } from './open-editor-button/StartExerciseButton'

export const OpenEditorButton = (
  props:
    | { status: 'locked'; command: string; links: null }
    | { status: 'available'; command: string; links: { start: string } }
    | {
        status: 'completed' | 'published'
        command: string
        links: { exercise: string }
      }
    | {
        status: 'iterated' | 'started'
        command: string
        links: { exercise: string }
      }
): JSX.Element | null => {
  let primarySegment

  switch (props.status) {
    case 'locked':
      primarySegment = <div>Open editor</div>
      break
    case 'available':
      primarySegment = <StartExerciseButton endpoint={props.links.start} />
      break
    case 'published':
    case 'completed':
      primarySegment = <a href={props.links.exercise}>Open editor</a>
      break
    default:
      primarySegment = <a href={props.links.exercise}>Continue in editor</a>
      break
  }

  return (
    <ComboButton
      className={props.status === 'locked' ? '--disabled' : undefined}
    >
      <ComboButton.PrimarySegment>{primarySegment}</ComboButton.PrimarySegment>
      <ComboButton.DropdownSegment>
        <CopyToClipboardButton textToCopy={props.command} />
      </ComboButton.DropdownSegment>
    </ComboButton>
  )
}
