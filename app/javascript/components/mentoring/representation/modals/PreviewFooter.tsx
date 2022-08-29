// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-nocheck
import React, { useState } from 'react'
import { StatusTab } from '../../inbox/StatusTab'
import { PrimaryButton } from '../right-pane/MentoringConversation'

export function PreviewFooter({
  numOfSolutions,
}: {
  numOfSolutions: string | number
}): JSX.Element {
  const [exampleStatus, setExampleStatus] = useState('example-1')

  return (
    <div className="flex flex-row justify-between items-center h-[70px] border-t-1 border-borderLight2 px-24">
      <div className="tabs flex flex-row child:px-12 child:py-10 child:text-14">
        <StatusTab
          currentStatus={exampleStatus}
          status="example-1"
          setStatus={setExampleStatus}
        >
          Example 1
        </StatusTab>
        <StatusTab
          currentStatus={exampleStatus}
          status="example-2"
          setStatus={setExampleStatus}
        >
          Example 2
        </StatusTab>
        <StatusTab
          currentStatus={exampleStatus}
          status="example-3"
          setStatus={setExampleStatus}
        >
          Example 3
        </StatusTab>
      </div>

      <div className="flex flex-row items-center">
        <div className="mr-32 text-right leading-150 text-15 text-btnBorder">
          You can edit this feedback anytime.
          <br />
          Your feedback will appear on{' '}
          <strong className="font-medium text-primaryBtnBorder">
            {numOfSolutions} solutions
          </strong>
        </div>
        <button className="mr-16 px-[18px] py-12 border border-1 border-primaryBtnBorder text-primaryBtnBorder rounded-8 font-semibold shadow-xsZ1v2">
          Cancel
        </button>
        <PrimaryButton className="px-[18px] py-12 !m-0">Submit</PrimaryButton>
        {/* <button className="btn-primary !px-18 py-12">Submit</button> */}
      </div>
    </div>
  )
}
