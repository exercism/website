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
  switch (props.status) {
    case 'locked':
      return (
        <ComboButton className="--disabled">
          <ComboButton.EditorSegment>
            <div>Open Editor</div>
          </ComboButton.EditorSegment>
          <ComboButton.DropdownSegment>
            <CopyToClipboardButton textToCopy={props.command} />
          </ComboButton.DropdownSegment>
        </ComboButton>
      )
    case 'available':
      return (
        <ComboButton>
          <ComboButton.EditorSegment>
            <StartExerciseButton endpoint={props.links.start} />
          </ComboButton.EditorSegment>
          <ComboButton.DropdownSegment>
            <CopyToClipboardButton textToCopy={props.command} />
          </ComboButton.DropdownSegment>
        </ComboButton>
      )
    case 'published':
    case 'completed':
      return (
        <ComboButton>
          <ComboButton.EditorSegment>
            <a href={props.links.exercise}>Open editor</a>
          </ComboButton.EditorSegment>
          <ComboButton.DropdownSegment>
            <CopyToClipboardButton textToCopy={props.command} />
          </ComboButton.DropdownSegment>
        </ComboButton>
      )
    default:
      return (
        <ComboButton>
          <ComboButton.EditorSegment>
            <a href={props.links.exercise}>Continue in editor</a>
          </ComboButton.EditorSegment>
          <ComboButton.DropdownSegment>
            <CopyToClipboardButton textToCopy={props.command} />
          </ComboButton.DropdownSegment>
        </ComboButton>
      )
  }
}
