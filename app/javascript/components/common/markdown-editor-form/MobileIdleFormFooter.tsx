import React from 'react'
import GraphicalIcon from '../GraphicalIcon'

export function MobileIdleFormFooter(): JSX.Element {
  return (
    <footer className="editor-footer">
      <button className="btn-primary btn-xs" type="button" disabled>
        <GraphicalIcon icon="send" />
        <span>Send</span>
      </button>
    </footer>
  )
}
