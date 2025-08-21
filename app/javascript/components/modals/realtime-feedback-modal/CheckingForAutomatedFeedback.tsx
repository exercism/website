import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { LoadingBar } from '@/components/common/LoadingBar'
import { FooterButtonContainer } from './components'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CheckingForAutomatedFeedback({
  onClick,
  showTakingTooLong,
}: {
  onClick: () => void
  showTakingTooLong: boolean
}): JSX.Element {
  const { t } = useAppTranslation('components/modals/realtime-feedback-modal')

  return (
    <>
      <div className="flex gap-40 items-start">
        <div className="flex flex-col">
          <div className="text-h4 mb-12">
            {t('checkingForAutomatedFeedback.checking')}{' '}
          </div>
          <p className="text-16 leading-150  mb-4">
            {t('checkingForAutomatedFeedback.inspectingCode')}
          </p>
          <p className="text-16 leading-150 font-semibold mt-4 mb-16">
            {t('checkingForAutomatedFeedback.processTime')}
          </p>

          <LoadingBar animationDuration={10} />
        </div>
        <GraphicalIcon
          height={160}
          width={160}
          className="mb-16"
          icon="mentoring"
          category="graphics"
        />
      </div>
      {showTakingTooLong && <TakingTooLong />}
      <FooterButtonContainer>
        <button onClick={onClick} className="btn-secondary btn-s mr-auto">
          {t('checkingForAutomatedFeedback.continueWaiting')}
        </button>
      </FooterButtonContainer>
    </>
  )
}

function TakingTooLong(): JSX.Element {
  const { t } = useAppTranslation('components/modals/realtime-feedback-modal')
  return (
    <div className="c-textblock-caution mt-12 mb-20">
      <div className="c-textblock-content text-p-base leading-150">
        {t('checkingForAutomatedFeedback.takingLonger')}
      </div>
    </div>
  )
}
