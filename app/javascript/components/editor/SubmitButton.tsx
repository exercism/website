import React, { forwardRef } from 'react'
import { GenericTooltip } from '../misc/ExercismTippy'

type Props = React.ButtonHTMLAttributes<HTMLButtonElement>

export const SubmitButton = forwardRef<HTMLButtonElement, Props>(
  ({ disabled, ...props }, ref) => {
    return (
      <GenericTooltip
        disabled={!disabled}
        content={
          'You need to get the tests passing before you can submit your solution'
        }
      >
        <div className="submit-btn">
          <button
            type="button"
            disabled={disabled}
            className="btn-primary btn-s"
            ref={ref}
            {...props}
          >
            <span>Submit</span>
          </button>
        </div>
      </GenericTooltip>
    )
  }
)
