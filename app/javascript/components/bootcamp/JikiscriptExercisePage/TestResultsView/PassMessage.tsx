// i18n-key-prefix: passMessage
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/TestResultsView
import React from 'react'
import { useContext } from 'react'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function PassMessage({ testIdx }: { testIdx: number }) {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/TestResultsView'
  )
  const {
    exercise: {
      config: { title },
    },
  } = useContext(JikiscriptExercisePageContext)
  return (
    <div className="success-message">
      <GraphicalIcon icon="bootcamp-completed-check-circle" />
      <div>
        <strong>{t('passMessage.youDidIt')}</strong>{' '}
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
