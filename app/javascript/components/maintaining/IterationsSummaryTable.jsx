import React, { useState, useEffect } from 'react'
import 'actioncable'

import consumer from '../../utils/action-cable-consumer'

function MaintainingIterationsSummaryTableRow({
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

export function MaintainingIterationsSummaryTable({ iterations }) {
  const [stateIterations, setIterations] = useState(iterations)

  useEffect(() => {
    const received = (data) => {
      const existingIterations = [...stateIterations]
      const existingIndex = existingIterations.findIndex(
        (iteration) => iteration.id === data.iteration.id
      )

      if (existingIndex !== -1) {
        existingIterations[existingIndex] = data.iteration
      } else {
        existingIterations.unshift(data.iteration)
      }

      setIterations(existingIterations)
    }

    const subscription = consumer.subscriptions.create(
      { channel: 'IterationChannel' },
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
        {stateIterations.map((iteration, idx) => (
          <MaintainingIterationsSummaryTableRow
            key={iteration.id}
            id={iteration.id}
            track={iteration.track}
            exercise={iteration.exercise}
            testsStatus={iteration.testsStatus}
            representationStatus={iteration.representationStatus}
            analysisStatus={iteration.analysisStatus}
            idx={idx}
          />
        ))}
      </tbody>
    </table>
  )
}
