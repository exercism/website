import React, { forwardRef } from 'react'
import { GraphicalIcon } from '@/components/common'
import { FetchingStatus } from './useChatGptFeedback'
import { GenericTooltip } from '@/components/misc/ExercismTippy'

type Props = {
  isProcessing: boolean
  sameSubmission: boolean
  noSubmission: boolean
  chatGptFetchingStatus: FetchingStatus
  passingTests: boolean
} & React.ButtonHTMLAttributes<HTMLButtonElement>

const TOOLTIP_TEXT = [
  'Please run the tests first.',
  'Please rerun the tests to continue.',
  'Tests are currently running.',
  'Awaiting response from ChatGPT. Please stand by.',
  'Congrats! The tests are passing! 🎉',
]

export const AskChatGptButton = forwardRef<HTMLButtonElement, Props>(
  (
    {
      noSubmission,
      sameSubmission,
      isProcessing,
      chatGptFetchingStatus,
      passingTests,
      ...props
    },
    ref
  ) => {
    const isDisabled =
      isProcessing ||
      noSubmission ||
      chatGptFetchingStatus === 'fetching' ||
      sameSubmission ||
      passingTests

    const tooltipTextIndex =
      Math.max(
        Number(noSubmission) * 1,
        Number(sameSubmission) * 2,
        Number(isProcessing) * 3,
        Number(chatGptFetchingStatus === 'fetching') * 4,
        Number(passingTests) * 5
      ) - 1

    return (
      <GenericTooltip
        disabled={!isDisabled}
        content={TOOLTIP_TEXT[tooltipTextIndex]}
      >
        <div className="mr-auto">
          <button
            type="button"
            className="btn-enhanced btn-s !ml-0 mr-auto ask-chatgpt-btn"
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
