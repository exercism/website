import React from 'react'
import { MutationStatus } from '@tanstack/react-query'
import { GraphicalIcon } from '..'
import { FormButton } from '../FormButton'

export const EditFormFooter = ({
  status,
  value,
  onCancel,
  onDelete,
}: {
  status: MutationStatus
  value: string
  onCancel?: (e: React.FormEvent) => void
  onDelete?: (e: React.FormEvent) => void
}): JSX.Element => {
  return (
    <footer className="editor-footer">
      {onCancel ? (
        <FormButton
          type="button"
          className="btn-default btn-xs"
          onClick={onCancel}
          status={status}
        >
          Cancel
        </FormButton>
      ) : null}
      {value.length === 0 ? (
        onDelete ? (
          <FormButton
            className="btn-alert btn-xs"
            type="button"
            status={status}
            onClick={onDelete}
          >
            <span>Delete</span>
          </FormButton>
        ) : null
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
