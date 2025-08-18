import { Icon } from '@/components/common'
import React from 'react'

export function Checked({ translation }: { translation: Translation }) {
  return (
    <div className="locale checked">
      <div className="header">
        <div className="text-h4">Locale Name (locale-code)</div>
        <div className="status">
          <Icon
            icon="completed-check-circle"
            className="c-icon"
            alt="Completed"
          />
          Checked
        </div>
      </div>
      <div className="body">
        <p className="text-16 leading-140 mb-10">
          This translation has been signed off by two translators. No action is
          needed.
        </p>
        <div className="locale-value mb-12">Translation Value</div>
      </div>
    </div>
  )
}
