import React from 'react'
import { MutationStatus } from '@tanstack/react-query'
import { GraphicalIcon } from '..'
import { FormButton } from '../FormButton'

export const NewFormFooter = ({
  status,
  value,
  onCancel,
}: {
  status: MutationStatus
  value: string
  onCancel?: (e: React.FormEvent) => void
}): JSX.Element => {
  if (onCancel && value.length === 0) {
    return (
      <footer className="editor-footer">
        <button type="button" className="btn-default btn-xs" onClick={onCancel}>
          Cancel
        </button>
      </footer>
    )
  } else {
    return (
      <footer className="editor-footer">
        <FormButton
          className="btn-primary btn-xs"
          type="submit"
          status={status}
          disabled={value.length === 0}
        >
          <GraphicalIcon icon="send" />
          <span>Send</span>
        </FormButton>
      </footer>
    )
  }
}
