import React from 'react'

type ManageExistingSolutionProps = {
  numPublished: number
  numCommentsEnabled: number
  commentStatusPhrase: string
  enableAllMutation: () => void
  disableAllMutation: () => void
}

export function ManageExistingSolution({
  numPublished,
  commentStatusPhrase,
  disableAllMutation,
  enableAllMutation,
  numCommentsEnabled,
}: ManageExistingSolutionProps): JSX.Element | null {
  if (numPublished === 0) return null
  return (
    <div className="form-footer">
      <div className="flex flex-col items-start">
        <h3 className="text-h5 mb-4">Manage existing solutions</h3>
        <p className="text-p-base mb-12">
          Currently, people can comment on {commentStatusPhrase} of your
          published solutions. Use the buttons below to{' '}
          <span className="font-medium">
            enable or disable comments on all your existing solutions.
          </span>
          .
        </p>
        <div className="flex gap-12">
          <button
            onClick={() => enableAllMutation()}
            disabled={numCommentsEnabled === numPublished}
            className="btn-m btn-enhanced"
          >
            Allow comments on all existing solutions
          </button>

          <button
            onClick={() => disableAllMutation()}
            disabled={numCommentsEnabled === 0}
            className="btn-m btn-enhanced"
          >
            Disable comments on all existing solutions
          </button>
        </div>
      </div>
    </div>
  )
}
