import React from 'react'
import { Modal } from './Modal'
import { GraphicalIcon } from '../common'

export const HelpModal = ({
  helpHtml,
  open,
  onClose,
  ...props
}: {
  helpHtml: string
  open: boolean
  onClose: () => void
}): JSX.Element => {
  return (
    <Modal open={open} onClose={onClose} className="m-editor-help" {...props}>
      <header>
        <GraphicalIcon icon="hints" category="graphics" />
        <h2>Help</h2>
      </header>

      <div
        className="c-textual-content --large"
        dangerouslySetInnerHTML={{ __html: helpHtml }}
      />
    </Modal>
  )
}
