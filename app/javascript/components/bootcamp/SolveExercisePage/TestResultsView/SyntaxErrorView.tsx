import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import React from 'react'

export function SyntaxErrorView() {
  return (
    <div className="text-center py-40">
      <GraphicalIcon
        className={`w-[48px] h-[48px] m-auto mb-20 filter-textColor6`}
        icon="bug"
      />
      <div className="text-h5 mb-8 text-textColor6">
        Oops! We couldn't run your code
      </div>
      <div className="mb-20 text-textColor6 leading-160 text-16">
        We encountered an error while running your code. Please check your code
        and try again.
      </div>
    </div>
  )
}
