import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { LoadingBar } from '@/components/common/LoadingBar'
import { FooterButtonContainer } from './components'

export function CheckingForAutomatedFeedback({
  onClick,
  showTakingTooLong,
}: {
  onClick: () => void
  showTakingTooLong: boolean
}): JSX.Element {
  return (
    <>
      <div className="flex gap-40 items-start">
        <div className="flex flex-col">
          <div className="text-h4 mb-12">Checking for automated feedback… </div>
          <p className="text-16 leading-150  mb-4">
            Our systems are inspecting your code to find both automated feedback
            and feedback given by mentors on similar solutions.
          </p>
          <p className="text-16 leading-150 font-semibold mt-4 mb-16">
            This process normally takes ~10 seconds.
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
          Continue without waiting
        </button>
      </FooterButtonContainer>
    </>
  )
}

function TakingTooLong(): JSX.Element {
  return (
    <div className="c-textblock-caution mt-12 mb-20">
      <div className="c-textblock-content text-p-base leading-150">
        Sorry, this is taking a little longer than expected. You may wish to
        continue without waiting. You can view any feedback on the iterations
        tab of the solution later.
      </div>
    </div>
  )
}
