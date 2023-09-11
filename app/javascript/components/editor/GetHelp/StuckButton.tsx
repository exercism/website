import React from 'react'
import { GraphicalIcon } from '@/components/common'

export function StuckButton({
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement>): JSX.Element {
  return (
    <button
      type="button"
      className="btn-enhanced btn-s !ml-0 mr-auto ask-chatgpt-btn"
      {...props}
    >
      <GraphicalIcon icon="automation" height={16} width={16} />
      <span>Stuck?</span>
    </button>
  )
}
