import React, { useState, useEffect } from 'react'
import 'actioncable'

import consumer from '../../utils/action-cable-consumer'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Submission = {
  uuid: string
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
  uuid,
  track,
  exercise,
  testsStatus,
  representationStatus,
  analysisStatus,
}: Submission) {
  return (
    <tr>
      <td>{uuid}</td>
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
}): JSX.Element {
  const { t } = useAppTranslation('components/maintaining')
  const [stateSubmissions, setSubmissions] = useState(submissions)

  useEffect(() => {
    const received = (event: SubmissionEvent) => {
      const existingSubmissions = [...stateSubmissions]
      const existingIndex = existingSubmissions.findIndex(
        (submission) => submission.uuid === event.submission.uuid
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

  return (
    <table>
      <thead>
        <tr>
          <th>{t('submissionsSummaryTable.id')}</th>
          <th>{t('submissionsSummaryTable.track')}</th>
          <th>{t('submissionsSummaryTable.exercise')}</th>
          <th>{t('submissionsSummaryTable.testStatus')}</th>
          <th>{t('submissionsSummaryTable.representationStatus')}</th>
          <th>{t('submissionsSummaryTable.analysesStatus')}</th>
        </tr>
      </thead>
      <tbody>
        {stateSubmissions.map((submission) => (
          <SubmissionsSummaryTableRow
            key={submission.uuid}
            uuid={submission.uuid}
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
