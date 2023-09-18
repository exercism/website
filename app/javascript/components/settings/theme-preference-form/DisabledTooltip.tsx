import { GraphicalIcon } from '@/components/common'
import React from 'react'
export function DisabledTooltip(): JSX.Element {
  return (
    <div className="flex items-center bg-russianViolet rounded-16 py-8 px-12 text-p-base text-aliceBlue">
      You must be an&nbsp;
      <strong style={{ color: 'inherit' }} className="flex items-center">
        Exercism Insider&nbsp;
        <GraphicalIcon icon="insiders" height={24} width={24} />
      </strong>
      &nbsp;to unlock this theme.
    </div>
  )
}
