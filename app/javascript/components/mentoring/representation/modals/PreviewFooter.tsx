import React, { SetStateAction } from 'react'
import { pluralizeWithNumber } from '../../../../utils/pluralizeWithNumber'
import { RepresentationData } from '../../../types'
import { StatusTab } from '../../inbox/StatusTab'
import { CancelButton } from '../common/CancelButton'
import { PrimaryButton } from '../common/PrimaryButton'

export function PreviewFooter({
  numOfSolutions,
  examples,
  selectedExample,
  setSelectedExample,
  onClose,
  onSubmit,
}: {
  numOfSolutions: number
  examples: Pick<RepresentationData, 'files' | 'instructions' | 'tests'>[]
  selectedExample: number
  setSelectedExample: React.Dispatch<SetStateAction<number>>
  onClose: () => void
  onSubmit: () => void
}): JSX.Element {
  return (
    <div className="flex flex-row justify-between items-center h-[70px] border-t-1 border-borderLight2 px-24">
      <div className="tabs flex flex-row child:px-12 child:py-10 child:text-14">
        {examples.map(
          (
            _: Pick<RepresentationData, 'files' | 'instructions' | 'tests'>,
            k: number
          ) => {
            return (
              <StatusTab
                key={`example-tab-${k}`}
                currentStatus={selectedExample}
                status={k}
                setStatus={setSelectedExample}
              >
                Example {k + 1}
              </StatusTab>
            )
          }
        )}
      </div>

      <div className="flex flex-row items-center">
        <div className="mr-32 text-right leading-150 text-15 text-btnBorder">
          You can edit this feedback anytime.
          <br />
          Your feedback will appear on{' '}
          <strong className="font-medium text-primaryBtnBorder">
            {pluralizeWithNumber(numOfSolutions, "solution")}
          </strong>
        </div>
        <CancelButton onClick={onClose} />
        <PrimaryButton onClick={onSubmit} className="px-[18px] py-12 !m-0">
          Submit
        </PrimaryButton>
      </div>
    </div>
  )
}
