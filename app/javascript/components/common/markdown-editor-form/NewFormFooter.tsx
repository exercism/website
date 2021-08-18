import React from 'react'
import { QueryStatus } from 'react-query'
import { GraphicalIcon, FormButton } from '..'

export const NewFormFooter = ({
  status,
  value,
  onCancel,
}: {
  status: QueryStatus
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
