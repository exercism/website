import React, { useState, useEffect } from 'react'
import 'actioncable'

import consumer from '../../utils/action-cable-consumer'

function SubmissionsSummaryTableRow({
  id,
  track,
  exercise,
  testsStatus,
  representationStatus,
  analysisStatus,
}) {
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

export function SubmissionsSummaryTable({ submissions }) {
  const [stateSubmissions, setSubmissions] = useState(submissions)

  useEffect(() => {
    const received = (data) => {
      const existingSubmissions = [...stateSubmissions]
      const existingIndex = existingSubmissions.findIndex(
        (submission) => submission.id === data.submission.id
      )

      if (existingIndex !== -1) {
        existingSubmissions[existingIndex] = data.submission
      } else {
        existingSubmissions.unshift(data.submission)
      }

      setSubmissions(existingSubmissions)
    }

    const subscription = consumer.subscriptions.create(
      { channel: 'SubmissionChannel' },
      { received }
    )
    return () => subscription.unsubscribe()
  })

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
        {stateSubmissions.map((submission, idx) => (
          <SubmissionsSummaryTableRow
            key={submission.id}
            id={submission.id}
            track={submission.track}
            exercise={submission.exercise}
            testsStatus={submission.testsStatus}
            representationStatus={submission.representationStatus}
            analysisStatus={submission.analysisStatus}
            idx={idx}
          />
        ))}
      </tbody>
    </table>
  )
}
