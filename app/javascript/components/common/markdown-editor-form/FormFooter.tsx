import React from 'react'
import { QueryStatus } from 'react-query'
import { GraphicalIcon, FormButton } from '..'
import { MarkdownEditorFormAction } from '../MarkdownEditorForm'
import { EditFormFooter } from './EditFormFooter'
import { NewFormFooter } from './NewFormFooter'

export const FormFooter = ({
  action,
  ...props
}: {
  status: QueryStatus
  value: string
  onCancel: (e: React.FormEvent) => void
  action: MarkdownEditorFormAction
}): JSX.Element => {
  switch (action) {
    case 'new':
      return <NewFormFooter {...props} />
    case 'edit':
      return <EditFormFooter {...props} />
  }
}
