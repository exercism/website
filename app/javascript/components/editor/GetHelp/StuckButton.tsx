// i18n-key-prefix: stuckButton
// i18n-namespace: components/editor/GetHelp
import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { TabIndex } from '@/components/Editor'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type StuckButtonProps = {
  insider: boolean
  tab: TabIndex
  setTab: React.Dispatch<React.SetStateAction<TabIndex>>
}

export function StuckButton({ setTab, tab }: StuckButtonProps): JSX.Element {
  const { t } = useAppTranslation('components/editor/GetHelp')
  return (
    <button
      type="button"
      disabled={['get-help', 'assistant'].includes(tab)}
      className="btn-enhanced btn-s !ml-0 mr-auto ask-chatgpt-btn"
      onClick={() => setTab('assistant')}
    >
      <GraphicalIcon icon="automation" height={16} width={16} />
      <span>{t('stuckButton.stuckGetHelp')}</span>
    </button>
  )
}

// end file
