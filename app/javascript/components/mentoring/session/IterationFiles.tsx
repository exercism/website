import React, { createContext, useEffect, useState } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { FileViewer } from './FileViewer'
import { useRequestQuery } from '../../../hooks/request-query'
import { File } from '../../types'
import { Loading } from '../../common'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'

const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => null,
})

type ComponentProps = {
  endpoint: string
  language: string
  indentSize: number
}

export const IterationFiles = (props: ComponentProps): JSX.Element => {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <Component {...props} />
    </ErrorBoundary>
  )
}

const ErrorFallback = ({ error }: { error: Error }) => (
  <div>
    <p>{error.message}</p>
  </div>
)

const DEFAULT_ERROR = new Error('Unable to load files')

const Component = ({
  endpoint,
  language,
  indentSize,
}: ComponentProps): JSX.Element | null => {
  const { data, error, status } = useRequestQuery<
    { files: File[] },
    Error | Response
  >([endpoint], { endpoint: endpoint, options: {} })
  const [tab, setTab] = useState<string | null>(null)

  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  useEffect(() => {
    if (!data) {
      return
    }

    if (data.files.length === 0) {
      return
    }

    setTab(data.files[0].filename)
  }, [data])

  if (status === 'loading') {
    return (
      <div className="c-iteration-pane">
        <Loading />
      </div>
    )
  }

  if (!data || !tab) {
    return null
  }

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (filename: string) => setTab(filename),
      }}
    >
      <div className="c-iteration-pane">
        <div className="tabs" role="tablist">
          {data.files.map((file) => (
            <Tab key={file.filename} id={file.filename} context={TabsContext}>
              {file.filename}
            </Tab>
          ))}
        </div>
        <div className="c-code-pane">
          {data.files.map((file) => (
            <Tab.Panel
              key={file.digest}
              id={file.filename}
              context={TabsContext}
            >
              <FileViewer
                file={file}
                language={language}
                indentSize={indentSize}
              />
            </Tab.Panel>
          ))}
        </div>
      </div>
    </TabsContext.Provider>
  )
}
