import React from 'react'
import { SubmissionMethod } from '../../types'
import { Icon } from '../../common/Icon'

export function SubmissionMethodIcon({
  submissionMethod,
}: {
  submissionMethod: SubmissionMethod
}) {
  switch (submissionMethod) {
    case SubmissionMethod.CLI:
      return (
        <Icon
          icon="cli"
          alt="Submitted via CLI"
          className="--icon --upload-method-icon"
        />
      )
    case SubmissionMethod.API:
      return (
        <Icon
          icon="editor"
          alt="Submitted via Editor"
          className="--icon --upload-method-icon"
        />
      )
    default:
      return null
  }
}
