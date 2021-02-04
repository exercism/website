import React, { useState } from 'react'
import { EndSessionModal } from '../../modals/EndSessionModal'
import { ModalProps } from '../../modals/Modal'

export const EndSessionButton = ({
  endpoint,
  modalProps,
}: {
  endpoint: string
  modalProps?: ModalProps
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        type="button"
        onClick={() => {
          setOpen(true)
        }}
      >
        End session
      </button>
      <EndSessionModal
        endpoint={endpoint}
        open={open}
        onCancel={() => {
          setOpen(false)
        }}
        {...modalProps}
      />
    </React.Fragment>
  )
}
