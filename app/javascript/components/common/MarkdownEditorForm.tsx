import React, { useCallback, useState, useEffect } from 'react'
import { MarkdownEditor, MarkdownEditorHandle } from './MarkdownEditor'
import { FormFooter } from './markdown-editor-form/FormFooter'
import { ErrorBoundary, useErrorHandler } from '../ErrorBoundary'
import { QueryStatus } from 'react-query'

const ErrorMessage = ({
  error,
  defaultError,
}: {
  error: unknown
  defaultError: Error
}) => {
  useErrorHandler(error, { defaultError: defaultError })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return <p>{error.message}</p>
}

export type MarkdownEditorFormAction = 'new' | 'edit'

export const MarkdownEditorForm = ({
  expanded,
  onSubmit,
  onClick = () => null,
  onCancel,
  onChange,
  contextId,
  value,
  status,
  error,
  defaultError,
  action,
}: {
  expanded: boolean
  onSubmit: () => void
  onClick?: () => void
  onCancel: () => void
  onChange: (value: string) => void
  contextId?: string
  value: string
  status: QueryStatus
  error: unknown
  defaultError: Error
  action: MarkdownEditorFormAction
}): JSX.Element => {
  const [editor, setEditor] = useState<MarkdownEditorHandle | null>(null)
  const classNames = [
    'c-markdown-editor',
    expanded ? '--expanded' : '--compressed',
  ].filter((className) => className.length > 0)

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      onSubmit()
    },
    [onSubmit]
  )

  const handleClick = useCallback(() => {
    onClick()
  }, [onClick])

  const handleEditorDidMount = useCallback((editor) => {
    setEditor(editor)
  }, [])

  const handleChange = useCallback(
    (value) => {
      onChange(value)
    },
    [onChange]
  )

  const handleCancel = useCallback(
    (e) => {
      e.stopPropagation()

      onCancel()
    },
    [onCancel]
  )

  useEffect(() => {
    if (!expanded || !editor) {
      return
    }

    editor.focus()
  }, [expanded, editor])

  return (
    <React.Fragment>
      <form
        onSubmit={handleSubmit}
        onClick={handleClick}
        className={classNames.join(' ')}
        data-testid="markdown-editor"
      >
        <MarkdownEditor
          contextId={contextId}
          value={value}
          onChange={handleChange}
          editorDidMount={handleEditorDidMount}
        />
        {expanded ? (
          <FormFooter
            onCancel={handleCancel}
            value={value}
            status={status}
            action={action}
          />
        ) : null}
      </form>
      <ErrorBoundary FallbackComponent={ErrorFallback} resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={defaultError} />
      </ErrorBoundary>
    </React.Fragment>
  )
}
