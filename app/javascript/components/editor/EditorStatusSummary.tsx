import React from 'react'
import { EditorStatus } from './useEditorStatus'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const EditorStatusSummary = ({
  status,
  error,
}: {
  status: EditorStatus
  error?: string
}): JSX.Element | null => {
  const { t } = useAppTranslation('components/editor/EditorStatusSummary.tsx')
  switch (status) {
    case EditorStatus.CREATE_SUBMISSION_FAILED:
      return (
        <p className="editor-status">
          {t('editorStatusSummary.error', { error })}
        </p>
      )
    case EditorStatus.REVERT_FAILED:
      return (
        <p className="editor-status">
          {t('editorStatusSummary.error', { error })}
        </p>
      )
    case EditorStatus.REVERTING:
      return (
        <p className="editor-status">
          {t('editorStatusSummary.revertingFiles')}
        </p>
      )
    default:
      return null
  }
}
