import React from 'react'
import { QueryStatus } from 'react-query'
import { GraphicalIcon, FormButton } from '..'

export const FormFooter = ({
  status,
  value,
  onCancel,
}: {
  status: QueryStatus
  value: string
  onCancel: (e: React.FormEvent) => void
}): JSX.Element => {
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
      <FormButton
        type="button"
        className="btn-default btn-xs"
        onClick={onCancel}
        status={status}
        disabled={value.length !== 0}
      >
        Cancel
      </FormButton>
    </footer>
  )
}
