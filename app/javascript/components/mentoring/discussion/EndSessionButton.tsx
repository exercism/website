import React, { useState } from 'react'
import { EndSessionModal } from '../../modals/EndSessionModal'

export const EndSessionButton = ({
  endpoint,
}: {
  endpoint: string
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
      <EndSessionModal endpoint={endpoint} open={open} />
    </React.Fragment>
  )
}
