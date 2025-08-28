import React from 'react'
import { useContext } from 'react'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'
import { GraphicalIcon } from '@/components/common'

export function PassMessage({ testIdx }: { testIdx: number }) {
  const {
    exercise: {
      config: { title },
    },
  } = useContext(JikiscriptExercisePageContext)
  return (
    <div className="success-message">
      <GraphicalIcon icon="bootcamp-completed-check-circle" />
      <div>
        <strong>You did it.</strong>{' '}
        {congratsMessages[stringToHash(title, testIdx)]}
      </div>
    </div>
  )
}

function stringToHash(input: string, testIdx: number): number {
  const PRIME = 31
  let hash = 0

  for (let i = 0; i < input.length; i++) {
    hash = (hash * PRIME + input.charCodeAt(i)) % congratsMessages.length
  }

  hash = (hash + testIdx * PRIME) % congratsMessages.length

  return hash
}

// ty djipity
const congratsMessages = [
  'Well done!',
  'Nice work!',
  'Fantastic job!',
  'Amazing effort!',
  'Great achievement!',
  'Congratulations!',
  'Congrats!',
]
