import React, { createContext, useEffect, useState } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { FileViewer } from './FileViewer'
import { useRequestQuery } from '../../../hooks/request-query'
import { File } from '../../types'
import { Loading } from '../../common'
import { ErrorBoundary, useErrorHandler } from 'react-error-boundary'
import { APIError } from '../../types'

const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

type ComponentProps = {
  endpoint: string
  language: string
}

export const IterationFiles = (props: ComponentProps): JSX.Element => (
  <ErrorBoundary FallbackComponent={ErrorFallback}>
    <Component {...props} />
  </ErrorBoundary>
)

const ErrorFallback = ({ error }: { error: Error }) => (
  <div>
    <p>{error.message}</p>
  </div>
)

const Component = ({
  endpoint,
  language,
}: ComponentProps): JSX.Element | null => {
  const { data, error, status } = useRequestQuery<
    { files: File[] } | { error: APIError },
    Error
  >(endpoint, { endpoint: endpoint, options: {} })

  const [tab, setTab] = useState<string | null>(null)
  const handleError = useErrorHandler()

  useEffect(() => {
    if (!data) {
      return
    }

    if ('files' in data) {
      if (data.files.length === 0) {
        return
      }

      setTab(data.files[0].filename)
    } else {
      handleError(new Error(data.error.message))
    }
  }, [data, handleError])

  useEffect(() => {
    if (status !== 'error') {
      return
    }

    if (error) {
      handleError(new Error('Unable to load files'))
    }
  }, [error, handleError, status])

  if (status === 'loading') {
    return <Loading />
  }

  if (data && 'files' in data && tab) {
    return (
      <TabsContext.Provider
        value={{
          current: tab,
          switchToTab: (filename: string) => setTab(filename),
        }}
      >
        <div className="tabs" role="tablist">
          {data.files.map((file) => (
            <Tab key={file.filename} id={file.filename} context={TabsContext}>
              {file.filename}
            </Tab>
          ))}
        </div>
        <div className="code">
          {data.files.map((file) => (
            <Tab.Panel
              key={file.filename}
              id={file.filename}
              context={TabsContext}
            >
              <FileViewer file={file} language={language} />
            </Tab.Panel>
          ))}
        </div>
      </TabsContext.Provider>
    )
  } else {
    return null
  }
}
