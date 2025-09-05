import React, { SetStateAction } from 'react'
import { pluralizeWithNumber } from '@/utils/pluralizeWithNumber'
import { StatusTab } from '../../inbox/StatusTab'
import { CancelButton } from '../common/CancelButton'
import { PrimaryButton } from '../common/PrimaryButton'
import type { RepresentationData } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Example = Pick<RepresentationData, 'files' | 'instructions' | 'testFiles'>
export function PreviewFooter({
  numOfSolutions,
  examples,
  selectedExample,
  setSelectedExample,
  onClose,
  onSubmit,
}: {
  numOfSolutions: number
  examples: Example[]
  selectedExample: number
  setSelectedExample: React.Dispatch<SetStateAction<number>>
  onClose: () => void
  onSubmit: () => void
}): JSX.Element {
  const { t } = useAppTranslation()

  return (
    <div className="flex flex-row justify-between items-center h-[70px] border-t-1 border-borderColor6 px-24 flex-shrink-0">
      <div className="tabs flex flex-row child:px-12 child:py-10 child:text-14">
        {examples.map((_: Example, k: number) => {
          return (
            <StatusTab
              key={`example-tab-${k}`}
              currentStatus={selectedExample}
              status={k}
              setStatus={setSelectedExample}
            >
              {t('previewFooter.example')} {k + 1}
            </StatusTab>
          )
        })}
      </div>

      <div className="flex flex-row items-center">
        <div className="mr-32 text-right leading-150 text-15 text-textColor6">
          {t('previewFooter.youCanEditFeedback')}
          <br />
          {t('previewFooter.feedbackWillAppearOn')}{' '}
          <strong className="font-medium text-textColor1">
            {pluralizeWithNumber(numOfSolutions, 'solution')}
          </strong>
        </div>
        <CancelButton onClick={onClose} />
        <PrimaryButton onClick={onSubmit} className="px-[18px] py-12 !m-0">
          {t('previewFooter.submit')}
        </PrimaryButton>
      </div>
    </div>
  )
}
