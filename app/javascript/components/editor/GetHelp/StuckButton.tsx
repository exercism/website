import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { TabIndex } from '@/components/Editor'

type StuckButtonProps = {
  insider: boolean
  tab: TabIndex
  setTab: React.Dispatch<React.SetStateAction<TabIndex>>
}

export function StuckButton({
  insider,
  setTab,
  tab,
}: StuckButtonProps): JSX.Element {
  return (
    <button
      type="button"
      disabled={['get-help', 'chat-gpt'].includes(tab)}
      className="btn-enhanced btn-s !ml-0 mr-auto ask-chatgpt-btn"
      onClick={() => setTab(insider ? 'chat-gpt' : 'get-help')}
    >
      <GraphicalIcon icon="automation" height={16} width={16} />
      <span>Stuck? {insider ? 'Ask ChatGPT' : 'Get help'}</span>
    </button>
  )
}
