import React from 'react'
import GraphicalIcon from '../GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function MobileIdleFormFooter(): JSX.Element {
  const { t } = useAppTranslation('components/common/markdown-editor-form')
  return (
    <footer className="editor-footer">
      <button className="btn-primary btn-xs" type="button" disabled>
        <GraphicalIcon icon="send" />
        <span>{t('mobileIdleFormFooter.send')}</span>
      </button>
    </footer>
  )
}
