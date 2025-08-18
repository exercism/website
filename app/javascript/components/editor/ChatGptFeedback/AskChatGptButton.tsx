// i18n-key-prefix: askChatGptButton
// i18n-namespace: components/editor/ChatGptFeedback
import React, { forwardRef } from 'react'
import { GraphicalIcon } from '@/components/common'
import { FetchingStatus } from './useChatGptFeedback'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { ConditionTextManager } from '@/utils/condition-text-manager'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
    const { t } = useAppTranslation('components/editor/ChatGptFeedback')

    const isDisabled =
      isProcessing ||
      noSubmission ||
      chatGptFetchingStatus === 'fetching' ||
      sameSubmission ||
      passingTests

    const tooltipText = new ConditionTextManager()
    tooltipText.append(
      noSubmission,
      t('askChatGptButton.pleaseRunTheTestsFirst')
    )
    tooltipText.append(
      sameSubmission,
      t('askChatGptButton.pleaseRerunTheTestsToContinue')
    )
    tooltipText.append(
      isProcessing,
      t('askChatGptButton.testsAreCurrentlyRunning')
    )
    tooltipText.append(
      chatGptFetchingStatus === 'fetching',
      t('askChatGptButton.awaitingResponseFromChatGPTPleaseStandBy')
    )
    tooltipText.append(
      passingTests,
      t('askChatGptButton.congratsTheTestsArePassing')
    )

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
            <span>{t('askChatGptButton.stuckAskChatGPT')}</span>
          </button>
        </div>
      </GenericTooltip>
    )
  }
)
