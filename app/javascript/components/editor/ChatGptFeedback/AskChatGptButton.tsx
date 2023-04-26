import React, { forwardRef } from 'react'
import { GraphicalIcon } from '@/components/common'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { FetchingStatus } from './useChatGptFeedback'

type Props = {
  isProcessing: boolean
  sameSubmission: boolean
  chatGptFetchingStatus: FetchingStatus
} & React.ButtonHTMLAttributes<HTMLButtonElement>

const TOOLTIP_TEXT = [
  'Please rerun the tests to continue.',
  'Tests are currently running.',
  'Awaiting response from ChatGPT. Please stand by.',
]

export const AskChatGptButton = forwardRef<HTMLButtonElement, Props>(
  ({ sameSubmission, isProcessing, chatGptFetchingStatus, ...props }, ref) => {
    const isDisabled =
      isProcessing || chatGptFetchingStatus === 'fetching' || sameSubmission

    const tooltipTextIndex =
      Math.max(
        Number(sameSubmission) * 1,
        Number(isProcessing) * 2,
        Number(chatGptFetchingStatus === 'fetching') * 3
      ) - 1

    return (
      <GenericTooltip
        disabled={!isDisabled}
        content={TOOLTIP_TEXT[tooltipTextIndex]}
      >
        <div className="run-tests-btn">
          <button
            type="button"
            className="btn-enhanced btn-s"
            disabled={isDisabled}
            ref={ref}
            {...props}
          >
            <GraphicalIcon icon="automation" />
            <span>Stuck? Ask ChatGPT</span>
          </button>
        </div>
      </GenericTooltip>
    )
  }
)
