import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import React from 'react'

export function SyntaxErrorView() {
  return (
    <div className="border-t-1 border-borderColor6">
      <div className="text-center py-40 px-40 max-w-[600px] mx-auto">
        <GraphicalIcon
          className={`w-[48px] h-[48px] m-auto mb-20 filter-textColor6`}
          icon="bug"
        />
        <div className="text-h5 mb-6 text-textColor6">
          Oops! Jiki couldn't understand your code.
        </div>
        <div className="mb-20 text-textColor6 leading-160 text-16 text-balance">
          No need to panic. Read and fix the error in the message above, then
          press "Check Scenarios" to try again.
        </div>
      </div>
    </div>
  )
}
