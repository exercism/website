import React from 'react'

export const EmptyList = (): JSX.Element => {
  return (
    <div className="flex flex-col lg:items-center lg:center">
      <h3 className="text-h5 text-textColor6 mb-2">
        No one has commented on this solution.
      </h3>
      <p className="text-p-base.text-textColor6">
        Be the first to add your comment!
      </p>
    </div>
  )
}
