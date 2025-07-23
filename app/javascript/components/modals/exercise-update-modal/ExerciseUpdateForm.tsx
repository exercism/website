import React, { createContext, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils/redirect-to'
import { typecheck } from '@/utils/typecheck'
import { GraphicalIcon, ExerciseIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { SolutionForStudent } from '@/components/types'
import { Tab, TabContext } from '@/components/common/Tab'
import { ExerciseDiff } from '../ExerciseUpdateModal'
import { DiffViewer } from './DiffViewer'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

const DEFAULT_ERROR = new Error('Unable to update exercise')

export const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => null,
})

export const ExerciseUpdateForm = ({
  diff,
  onCancel,
}: {
  diff: ExerciseDiff
  onCancel: () => void
}): JSX.Element => {
  const [tab, setTab] = useState(diff.files[0].relativePath)
  const { t } = useAppTranslation('components/modals/exercise-update-modal')

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<SolutionForStudent>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: diff.links.update,
        method: 'PATCH',
        body: null,
      })

      return fetch.then((json) =>
        typecheck<SolutionForStudent>(json, 'solution')
      )
    },
    onSuccess: (solution) => {
      redirectTo(solution.privateUrl)
    },
  })

  return (
    <>
      <header className="header">
        <h2>
          <Trans
            ns="components/modals/exercise-update-modal"
            i18nKey={'exerciseUpdateForm.header'}
            components={{
              icon: <ExerciseIcon iconUrl={diff.exercise.iconUrl} />,
            }}
            values={{ exerciseTitle: diff.exercise.title }}
          />
        </h2>
      </header>
      <TabsContext.Provider
        value={{
          current: tab,
          switchToTab: (id: string) => setTab(id),
        }}
      >
        <div className="tabs">
          {diff.files.map((file) => (
            <Tab
              id={file.relativePath}
              context={TabsContext}
              key={file.relativePath}
            >
              {file.relativePath}
            </Tab>
          ))}
        </div>

        {diff.files.map((file) => (
          <Tab.Panel
            id={file.relativePath}
            context={TabsContext}
            key={file.relativePath}
          >
            <DiffViewer diff={file.diff} />
          </Tab.Panel>
        ))}
      </TabsContext.Provider>
      <div className="warning">{t('exerciseUpdateForm.warning')}</div>
      <form data-turbo="false">
        <FormButton
          type="button"
          onClick={() => mutation()}
          status={status}
          className="btn-primary btn-m"
        >
          <GraphicalIcon icon="reset" />
          <span>{t('exerciseUpdateForm.updateExercise')}</span>
        </FormButton>
        <FormButton
          type="button"
          onClick={onCancel}
          status={status}
          className="dismiss-btn"
        >
          {t('exerciseUpdateForm.dismiss')}
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </>
  )
}
