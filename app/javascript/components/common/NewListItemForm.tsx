import React, { useCallback, useState } from 'react'
import { sendRequest } from '../../utils/send-request'
import { useMutation } from '@tanstack/react-query'
import { typecheck } from '../../utils/typecheck'
import { MarkdownEditorForm } from './MarkdownEditorForm'

export const NewListItemForm = <T extends unknown>({
  endpoint,
  expanded,
  contextId,
  onSuccess,
  onExpanded,
  onCompressed,
  defaultError,
}: {
  endpoint: string
  expanded: boolean
  contextId: string
  onSuccess: (item: T) => void
  onExpanded?: () => void
  onCompressed?: () => void
  defaultError: Error
}): JSX.Element => {
  const [value, setValue] = useState(
    localStorage.getItem(`smde_${contextId}`) || ''
  )
  const handleSuccess = useCallback(
    (item: T) => {
      setValue('')
      onSuccess(item)
    },
    [onSuccess]
  )

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<T>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'POST',
        body: JSON.stringify({ content: value }),
      })

      return fetch.then((json) => typecheck<T>(json, 'item'))
    },
    {
      onSuccess: handleSuccess,
    }
  )

  const handleSubmit = useCallback(() => {
    mutation()
  }, [mutation])

  const handleClick = useCallback(() => {
    if (expanded || !onExpanded) {
      return
    }

    onExpanded()
  }, [expanded, onExpanded])

  const handleCancel = useCallback(() => {
    if (!onCompressed) {
      return
    }

    onCompressed()
  }, [onCompressed])

  const handleChange = useCallback(
    (value: string) => {
      setValue(value)
    },
    [setValue]
  )

  return (
    <MarkdownEditorForm
      onSubmit={handleSubmit}
      onClick={onExpanded ? handleClick : undefined}
      onCancel={onCompressed ? handleCancel : undefined}
      onChange={handleChange}
      contextId={contextId}
      value={value}
      expanded={expanded}
      status={status}
      error={error}
      defaultError={defaultError}
      action="new"
    />
  )
}
