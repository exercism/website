import React, { forwardRef } from 'react'
import { GraphicalIcon } from '@/components/common'
import { GenericTooltip } from '@/components/misc/ExercismTippy'

type Props = React.ButtonHTMLAttributes<HTMLButtonElement>

export const AskChatGptButton = forwardRef<HTMLButtonElement, Props>(
  ({ ...props }, ref) => {
    return (
      <GenericTooltip
        disabled={true}
        content={'You have to be an insiders to access this feature'}
      >
        <div className="run-tests-btn">
          <button
            type="button"
            className="btn-enhanced btn-s"
            ref={ref}
            {...props}
          >
            <GraphicalIcon icon="automation" />
            <span>Ask ChatGPT</span>
          </button>
        </div>
      </GenericTooltip>
    )
  }
)
