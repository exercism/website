import React from 'react'
import { RepresentationFeedbackType } from '../../../types'
export const CommentTag = ({ type }: { type: RepresentationFeedbackType }):JSX.Element|null => {
  switch (type) {
    case 'essential':
      return (
        <div className="text-13 leading-170 font-mono font-bold rounded-3 px-8 mb-8 bg-red text-white !w-fit">
          Essential
        </div>
      )
    case 'actionable':
      return (
        <div className="text-13 leading-170 font-mono font-bold rounded-3 px-8 mb-8 bg-warning text-white !w-fit">
          Recommended
        </div>
      )
    default:
      return null
  }
}
