// i18n-key-prefix: chatGptUpsellContent
// i18n-namespace: components/editor/ChatGptFeedback
import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ChatGptUpsellContent = (): JSX.Element => {
  const { t } = useAppTranslation('components/editor/ChatGptFeedback')
  return (
    <div className="  px-24 pt-16 pb-24 text-center">
      <div className="border-gradient-lightPurple border-2 rounded-8 px-24 py-16 flex flex-col items-center">
        <GraphicalIcon icon="insiders" className="w-[48px] h-[48px] mb-16" />
        <h2 className="text-h3 mb-2">
          {t('chatGptUpsellContent.exercismInsiders')}
        </h2>
        <p className="text-h5 mb-16 max-w-[520px]">
          {t(
            'chatGptUpsellContent.donateToExercismAndGetBehindTheScenesAccessAndBonusFeatures'
          )}
        </p>
        <div className="text-p-base max-w-[520px] mb-16">
          {t(
            'chatGptUpsellContent.needHelpGettingUnstuckUnlockOurChatGPTIntegration'
          )}
        </div>

        <a href="/insiders" className="btn-m btn-primary">
          {t('chatGptUpsellContent.learnMore')}
        </a>
      </div>
    </div>
  )
}
