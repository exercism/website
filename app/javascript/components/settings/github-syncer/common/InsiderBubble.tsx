import GraphicalIcon from '@/components/common/GraphicalIcon'
import React from 'react'

export function InsiderBubble() {
  return (
    <div className="flex items-center gap-8 rounded-100 font-medium bg-orange text-textColor1 border-1 border-textColor1 py-4 px-8">
      <GraphicalIcon icon="insiders" height={16} width={16} />
      Insiders only
    </div>
  )
}
