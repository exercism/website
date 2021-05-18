import React, { useState } from 'react'
import { TestsFailedModal } from '../../modals/TestsFailedModal'

export const TestsFailedButton = ({
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
      <TestsFailedModal
        open={open}
        onClose={() => setOpen(false)}
        endpoint={endpoint}
        className="m-tests-failed"
      />
    </React.Fragment>
  )
}
