import React, {
  useCallback,
  useRef,
  useState,
  useEffect,
  createContext,
} from 'react'
import { File } from '../types'
import { CodeMirror, Handler } from '../misc/CodeMirror'
import { Tab, TabContext } from '../common/Tab'
import { EditorSettings } from '../editor/types'
import { LegacyFileBanner } from './LegacyFileBanner'

export type FileEditorHandle = {
  getFiles: () => File[]
  setFiles: (files: File[]) => void
  openPalette: () => void
}

export const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => {},
})

export function FileEditorCodeMirror({
  language,
  editorDidMount,
  onRunTests,
  onSubmit,
  files,
  settings,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  onRunTests: () => void
  onSubmit: () => void
  settings: EditorSettings
  files: File[]
}): JSX.Element {
  const [tab, setTab] = useState(files[0].filename)
  const containerRef = useRef<HTMLDivElement>(null)
  const editorRefs = useRef<Record<string, Handler>>({})

  const setFiles = useCallback((files: File[]) => {
    const editors: Record<string, Handler> = {}

    files.forEach((file) => {
      const editor = editorRefs.current[file.filename]
      editor.setValue(file.content)

      editors[file.filename] = editor
    })

    editorRefs.current = editors
  }, [])

  const getFiles = useCallback(() => {
    return Object.keys(editorRefs.current)
      .map((filename) => {
        const editor = editorRefs.current[filename]
        const file = files.find((f) => f.filename === filename)

        if (!file) {
          return
        }

        return {
          filename: file.filename,
          content: editor.getValue() || '',
          type: file.type,
        }
      })
      .filter((f) => f !== undefined)
  }, [files])

  const openPalette = useCallback(() => null, [])

  const handleDelete = useCallback(
    (fileToDelete: File) => {
      return () => {
        setFiles(files.filter((f) => f.filename !== fileToDelete.filename))
      }
    },
    [files, setFiles]
  )

  useEffect(() => {
    editorDidMount({ getFiles, setFiles, openPalette })
  }, [editorDidMount, getFiles, openPalette, setFiles])

  return (
    <TabsContext.Provider
      value={{
        current: tab,
        switchToTab: (id: string) => setTab(id),
      }}
    >
      <div ref={containerRef} className="c-iteration-pane">
        <div className="tabs">
          {files.map((file) => (
            <Tab context={TabsContext} key={file.filename} id={file.filename}>
              {file.filename}
            </Tab>
          ))}
        </div>
        {files.map((file, index) => (
          <Tab.Panel
            context={TabsContext}
            key={file.filename}
            id={file.filename}
          >
            {file.type === 'legacy' ? (
              <LegacyFileBanner onDelete={handleDelete(file)} />
            ) : null}
            <CodeMirror
              key={file.filename}
              value={file.content}
              editorDidMount={(editor) => {
                const oldEditors = editorRefs.current

                oldEditors[file.filename] = editor

                editorRefs.current = oldEditors
              }}
              tabSize={settings.tabSize}
              useSoftTabs={settings.useSoftTabs}
              language={language}
              wrap={settings.wrap !== 'off'}
              isTabCaptured={settings.tabBehavior === 'captured'}
              theme={settings.theme}
              readonly={file.type === 'legacy'}
              commands={[
                {
                  key: 'F2',
                  run: () => {
                    onRunTests()
                    return true
                  },
                },
                {
                  key: 'F3',
                  run: () => {
                    onSubmit()
                    return true
                  },
                },
              ]}
            />
          </Tab.Panel>
        ))}
      </div>
    </TabsContext.Provider>
  )
}
