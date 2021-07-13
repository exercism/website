import React from 'react'
import { QueryStatus } from 'react-query'
import { GraphicalIcon, FormButton } from '..'

export const EditFormFooter = ({
  status,
  value,
  onCancel,
  onDelete,
}: {
  status: QueryStatus
  value: string
  onCancel: (e: React.FormEvent) => void
  onDelete?: (e: React.FormEvent) => void
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
      {value.length === 0 ? (
        <FormButton
          className="btn-alert btn-xs"
          type="button"
          status={status}
          onClick={onDelete}
          disabled={onDelete === undefined}
        >
          <span>Delete</span>
        </FormButton>
      ) : (
        <FormButton
          className="btn-primary btn-xs"
          type="submit"
          status={status}
        >
          <GraphicalIcon icon="send" />
          <span>Update</span>
        </FormButton>
      )}
    </footer>
  )
}
