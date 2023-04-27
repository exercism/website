import React, { forwardRef } from 'react'
import { GraphicalIcon } from '@/components/common'
import { FetchingStatus } from './useChatGptFeedback'

type Props = {
  isProcessing: boolean
  sameSubmission: boolean
  chatGptFetchingStatus: FetchingStatus
  passingTests: boolean
} & React.ButtonHTMLAttributes<HTMLButtonElement>

export const AskChatGptButton = forwardRef<HTMLButtonElement, Props>(
  (
    {
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
      chatGptFetchingStatus === 'fetching' ||
      sameSubmission ||
      passingTests

    return (
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
    )
  }
)
