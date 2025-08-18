// i18n-key-prefix: emptyIterations
// i18n-namespace: components/student/iterations-list
import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { useIsMounted } from 'use-is-mounted'
import { redirectTo } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import { ProminentLink, GraphicalIcon } from '@/components/common'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { Exercise } from '../IterationsList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  startExercise: string
  solvingExercisesLocally: string
}

type Solution = {
  links: {
    exercise: string
  }
}

const DEFAULT_ERROR = new Error('Unable to start exercise')

export const EmptyIterations = ({
  exercise,
  links,
}: {
  exercise: Exercise
  links: Links
}): JSX.Element => {
  const { t } = useAppTranslation('components/student/iterations-list')
  const isMountedRef = useIsMounted()
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<Solution>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: links.startExercise,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: (solution) => {
      if (!isMountedRef.current) {
        return
      }

      redirectTo(solution.links.exercise)
    },
  })

  return (
    <div className="lg-container container">
      <section className="zero-state">
        <h2>{t('emptyIterations.noIterations')}</h2>
        <p>{t('emptyIterations.iterationsWillAppear')}</p>
        <div className="box">
          {exercise.hasTestRunner ? (
            <div className="editor">
              <h4>{t('emptyIterations.viaExercismEditor')}</h4>
              <FormButton
                status={status}
                onClick={() => mutation()}
                type="button"
                className="editor-btn btn-primary btn-m"
              >
                <GraphicalIcon icon="editor" />
                <span>{t('emptyIterations.startInEditor')}</span>
              </FormButton>
              <FetchingBoundary
                status={status}
                error={error}
                defaultError={DEFAULT_ERROR}
              />
            </div>
          ) : null}
          <div className="cli">
            <h4>{t('emptyIterations.workLocally')}</h4>
            <CopyToClipboardButton textToCopy={exercise.downloadCmd} />
          </div>
        </div>
        <ProminentLink
          link={links.solvingExercisesLocally}
          text={t('emptyIterations.learnMoreSolvingExercisesLocally')}
        />
      </section>
    </div>
  )
}
