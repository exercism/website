import React, { useState, useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../utils/send-request'
import { typecheck } from '../../utils/typecheck'
import { MarkdownEditorForm } from './MarkdownEditorForm'

type MutationAction = 'update' | 'delete'

type ListItem = {
  contentMarkdown: string
  links: {
    edit?: string
    delete?: string
  }
}

export const EditListItemForm = <T extends ListItem>({
  item,
  onUpdate,
  onDelete,
  onCancel,
  defaultError,
}: {
  item: T
  onUpdate?: (item: T) => void
  onDelete?: (item: T) => void
  onCancel: () => void
  defaultError: Error
}): JSX.Element => {
  const [value, setValue] = useState(item.contentMarkdown)

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<T, unknown, MutationAction>(
    async (action) => {
      const endpoint = action === 'update' ? item.links.edit : item.links.delete

      if (!endpoint) {
        throw `No endpoint for action ${action}`
      }

      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: action === 'update' ? 'PATCH' : 'DELETE',
        body: JSON.stringify({ content: value }),
      })

      return fetch.then((json) => typecheck<T>(json, 'item'))
    },
    {
      onSuccess: (data, action) => {
        switch (action) {
          case 'delete': {
            if (!onDelete) {
              return
            }

            onDelete(data)

            break
          }
          case 'update': {
            if (!onUpdate) {
              return
            }

            onUpdate(data)

            break
          }
        }
      },
    }
  )
  const handleSubmit = useCallback(() => {
    mutation('update')
  }, [mutation])
  const handleDelete = useCallback(() => {
    mutation('delete')
  }, [mutation])
  const handleCancel = useCallback(() => onCancel(), [onCancel])
  const handleChange = useCallback((value) => setValue(value), [setValue])

  return (
    <MarkdownEditorForm
      expanded
      onSubmit={handleSubmit}
      onCancel={handleCancel}
      onChange={handleChange}
      onDelete={item.links.delete ? handleDelete : undefined}
      value={value}
      status={status}
      error={error}
      defaultError={defaultError}
      action="edit"
    />
  )
}
