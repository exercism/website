import React, { useState, useEffect } from 'react'
import 'actioncable'

import consumer from '../../utils/action-cable-consumer'

type Submission = {
  id: string
  track: string
  exercise: string
  testsStatus: string
  representationStatus: string
  analysisStatus: string
}

type SubmissionEvent = {
  submission: Submission
}

function SubmissionsSummaryTableRow({
  id,
  track,
  exercise,
  testsStatus,
  representationStatus,
  analysisStatus,
}: Submission) {
  return (
    <tr>
      <td>{id}</td>
      <td>{track}</td>
      <td>{exercise}</td>
      <td>{testsStatus}</td>
      <td>{representationStatus}</td>
      <td>{analysisStatus}</td>
    </tr>
  )
}

export function SubmissionsSummaryTable({
  submissions,
}: {
  submissions: readonly Submission[]
}) {
  const [stateSubmissions, setSubmissions] = useState(submissions)

  useEffect(() => {
    const received = (event: SubmissionEvent) => {
      const existingSubmissions = [...stateSubmissions]
      const existingIndex = existingSubmissions.findIndex(
        (submission) => submission.id === event.submission.id
      )

      if (existingIndex !== -1) {
        existingSubmissions[existingIndex] = event.submission
      } else {
        existingSubmissions.unshift(event.submission)
      }

      setSubmissions(existingSubmissions)
    }

    const subscription = consumer.subscriptions.create(
      { channel: 'SubmissionChannel' },
      { received }
    )
    return () => subscription.unsubscribe()
  })
  console.log(submissions)

  return (
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Track</th>
          <th>Exercise</th>
          <th>Test status</th>
          <th>Representation status</th>
          <th>Analyses status</th>
        </tr>
      </thead>
      <tbody>
        {stateSubmissions.map((submission) => (
          <SubmissionsSummaryTableRow
            key={submission.id}
            id={submission.id}
            track={submission.track}
            exercise={submission.exercise}
            testsStatus={submission.testsStatus}
            representationStatus={submission.representationStatus}
            analysisStatus={submission.analysisStatus}
          />
        ))}
      </tbody>
    </table>
  )
}
