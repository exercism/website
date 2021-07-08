import React from 'react'
import { QueryStatus } from 'react-query'
import { GraphicalIcon, FormButton } from '..'

export const EditFormFooter = ({
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
        type="button"
        className="btn-default btn-xs"
        onClick={onCancel}
        status={status}
      >
        Cancel
      </FormButton>
      <FormButton
        className="btn-primary btn-xs"
        type="submit"
        status={status}
        disabled={value.length === 0}
      >
        <GraphicalIcon icon="send" />
        <span>Update</span>
      </FormButton>
    </footer>
  )
}
