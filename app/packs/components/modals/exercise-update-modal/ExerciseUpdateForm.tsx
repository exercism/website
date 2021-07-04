import React, { createContext, useState } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../utils/send-request'
import { ExerciseDiff } from '../ExerciseUpdateModal'
import { useIsMounted } from 'use-is-mounted'
import { GraphicalIcon, ExerciseIcon, FormButton } from '../../common'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'
import { SolutionForStudent } from '../../types'
import { typecheck } from '../../../utils/typecheck'
import { DiffViewer } from './DiffViewer'
import { Tab, TabContext } from '../../common/Tab'

const DEFAULT_ERROR = new Error('Unable to update exercise')

export const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export const ExerciseUpdateForm = ({
  diff,
  onCancel,
}: {
  diff: ExerciseDiff
  onCancel: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [tab, setTab] = useState(diff.files[0].filename)

  const [mutation, { status, error }] = useMutation<SolutionForStudent>(
    () => {
      return sendRequest({
        endpoint: diff.links.update,
        method: 'PATCH',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        return typecheck<SolutionForStudent>(json, 'solution')
      })
    },
    {
      onSuccess: (solution) => {
        window.location.replace(solution.privateUrl)
      },
    }
  )

  return (
    <>
      <header className="header">
        <h2>
          See what&apos;s changed on
          <ExerciseIcon iconUrl={diff.exercise.iconUrl} />
          {diff.exercise.title}
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
            <Tab id={file.filename} context={TabsContext} key={file.filename}>
              {file.filename}
            </Tab>
          ))}
        </div>

        {diff.files.map((file) => (
          <Tab.Panel
            id={file.filename}
            context={TabsContext}
            key={file.filename}
          >
            <DiffViewer diff={file.diff} />
          </Tab.Panel>
        ))}
      </TabsContext.Provider>
      <div className="warning">
        By updating to the latest version, your solution may fail the tests and
        need to be updated.
      </div>
      <form>
        <FormButton
          type="button"
          onClick={() => mutation()}
          status={status}
          className="btn-primary btn-m"
        >
          <GraphicalIcon icon="reset" />
          <span>Update exercise</span>
        </FormButton>
        <FormButton
          type="button"
          onClick={onCancel}
          status={status}
          className="dismiss-btn"
        >
          Dismiss
        </FormButton>
        <ErrorBoundary resetKeys={[status]}>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      </form>
    </>
  )
}
