import React, { createContext, useEffect, useState } from 'react'
import { Tab, TabContext } from '../../common/Tab'
import { FileViewer } from './FileViewer'
import { useRequestQuery } from '../../../hooks/request-query'
import { File } from '../../types'
import { Loading } from '../../common'

const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export const IterationFiles = ({
  endpoint,
  language,
}: {
  endpoint: string
  language: string
}): JSX.Element | null => {
  const { data, status } = useRequestQuery<{
    files: File[]
  }>(endpoint, { endpoint: endpoint, options: {} })
  const [tab, setTab] = useState<string | null>(null)

  useEffect(() => {
    if (!data) {
      return
    }

    setTab(data.files[0].filename)
  }, [data])

  if (status === 'loading') {
    return <Loading />
  }

  if (status === 'success' && data && tab) {
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
