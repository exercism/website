import React, { useState, useEffect, Fragment } from 'react'
import 'actioncable'

import consumer from '../../utils/action-cable-consumer'

type Submission = {
  id: string
  testsStatus: unknown
}

function SubmissionSummary({ id, testsStatus }: Submission) {
  return (
    <div>
      {id}: {testsStatus}
    </div>
  )
}

export function SubmissionsSummaryTable({
  solutionId,
  submissions,
}: {
  solutionId: string
  submissions: readonly Submission[]
}) {
  const [stateSubmissions, setSubmissions] = useState(submissions)

  useEffect(() => {
    const received = (data: { submissions: readonly Submission[] }) =>
      setSubmissions(data.submissions)

    const subscription = consumer.subscriptions.create(
      { channel: 'SubmissionsChannel', solution_id: solutionId },
      {
        received,
      }
    )
    return () => subscription.unsubscribe()
  }, [solutionId])

  return (
    <Fragment>
      {stateSubmissions.map((submission) => {
        return (
          <SubmissionSummary
            key={submission.id}
            id={submission.id}
            testsStatus={submission.testsStatus}
          />
        )
      })}
    </Fragment>
  )
}
