import React from 'react'
import { useContext } from 'react'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'
import { GraphicalIcon } from '@/components/common'

export function PassMessage({ testIdx }: { testIdx: number }) {
  const {
    exercise: {
      config: { title },
    },
  } = useContext(SolveExercisePageContext)
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

// function seededRandom(seed: number): () => number {
//   const MAX = 2147483647;
//   let s = seed % MAX;
//   return () => {
//     s = (s * 16807) % MAX;
//     return (s - 1) / (MAX - 1);
//   };
// }

// function shuffle<T>(array: T[], seed: number): T[] {
//   const random = seededRandom(seed);
//   const result = array.slice();
//   for (let i = result.length - 1; i > 0; i--) {
//     const j = Math.floor(random() * (i + 1));
//     [result[i], result[j]] = [result[j], result[i]];
//   }
//   return result;
// }

function stringToHash(input: string, testIdx: number): number {
  const PRIME = 31
  let hash = 0

  for (let i = 0; i < input.length; i++) {
    hash =
      (hash * PRIME + input.charCodeAt(i) + testIdx) % congratsMessages.length
  }

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
]
