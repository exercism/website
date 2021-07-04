import React, { useState } from 'react'
import { TestRunModal } from '../../modals/TestRunModal'

export const TestRunStatusButton = ({
  endpoint,
  children,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & {
  endpoint: string
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button type="button" onClick={() => setOpen(!open)} {...props}>
        {children}
      </button>
      <TestRunModal
        open={open}
        onClose={() => setOpen(false)}
        endpoint={endpoint}
      />
    </React.Fragment>
  )
}
