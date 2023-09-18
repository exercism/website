import React, { forwardRef } from 'react'
import { GraphicalIcon } from '@/components/common'
import { FetchingStatus } from './useChatGptFeedback'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { ConditionTextManager } from '@/utils/condition-text-manager'

type Props = {
  isProcessing: boolean
  sameSubmission: boolean
  noSubmission: boolean
  chatGptFetchingStatus: FetchingStatus
  passingTests: boolean
  insider: boolean
} & React.ButtonHTMLAttributes<HTMLButtonElement>

export const AskChatGptButton = forwardRef<HTMLButtonElement, Props>(
  (
    {
      noSubmission,
      sameSubmission,
      isProcessing,
      chatGptFetchingStatus,
      passingTests,
      insider,
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

    const tooltipText = new ConditionTextManager()
    tooltipText.append(noSubmission, 'Please run the tests first.')
    tooltipText.append(sameSubmission, 'Please rerun the tests to continue.')
    tooltipText.append(isProcessing, 'Tests are currently running.')
    tooltipText.append(
      chatGptFetchingStatus === 'fetching',
      'Awaiting response from ChatGPT. Please stand by.'
    )
    tooltipText.append(passingTests, 'Congrats! The tests are passing! 🎉')

    return (
      <GenericTooltip
        disabled={!isDisabled || !insider}
        content={tooltipText.getLastTrueText()}
      >
        <div className="mr-auto ask-chatgpt-btn-wrapper">
          <button
            type="button"
            className="btn-enhanced btn-s !ml-0 mr-auto ask-chatgpt-btn"
            disabled={isDisabled && insider}
            ref={ref}
            {...props}
          >
            <GraphicalIcon icon="automation" height={16} width={16} />
            <span>Stuck? Ask ChatGPT</span>
          </button>
        </div>
      </GenericTooltip>
    )
  }
)
