import React, {
  useCallback,
  useRef,
  useState,
  useEffect,
  createContext,
  lazy,
  Suspense,
} from 'react'
import { File } from '../types'
import type { Handler } from '../misc/CodeMirror'
import { Tab, TabContext } from '../common/Tab'
import { EditorSettings } from '../editor/types'
import { LegacyFileBanner } from './LegacyFileBanner'
import { RenderLoader } from '@/components/common'
import { useDeepMemo } from '@/hooks/use-deep-memo'
const CodeMirror = lazy(() => import('../misc/CodeMirror'))

export type FileEditorHandle = {
  getFiles: () => File[]
  setFiles: (files: File[]) => void
  focus: () => void
}

export const TabsContext = createContext<TabContext>({
  current: '',
  switchToTab: () => null,
})

export function FileEditorCodeMirror({
  language,
  editorDidMount,
  files: defaultFiles,
  settings,
  readonly,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  onRunTests: () => void
  onSubmit: () => void
  settings: EditorSettings
  files: File[]
  readonly: boolean
}): JSX.Element {
  const [files, setFiles] = useState(defaultFiles)
  const [tab, setTab] = useState(files[0].filename)
  const containerRef = useRef<HTMLDivElement>(null)
  const editorRefs = useRef<Record<string, Handler>>({})

  const cachedFiles = useDeepMemo(files)
  useEffect(() => {
    const editors: Record<string, Handler> = {}

    cachedFiles.forEach((file) => {
      const editor = editorRefs.current[file.filename]

      if (!editor) {
        return
      }

      editor.setValue(file.content)

      editors[file.filename] = editor
    })

    editorRefs.current = editors
  }, [cachedFiles])

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
      .filter((f): f is File => f !== undefined)
  }, [files])

  const handleDelete = useCallback(
    (fileToDelete: File) => {
      return () => {
        const currentFiles = getFiles()
        const index = currentFiles.findIndex(
          (f) => f.filename === fileToDelete.filename
        )

        if (index === -1) {
          throw 'File not found!'
        }

        if (index === 0) {
          setTab(currentFiles[1].filename)
        } else {
          setTab(currentFiles[index - 1].filename)
        }

        setFiles(
          currentFiles.filter((f) => f.filename !== fileToDelete.filename)
        )
      }
    },
    [files, getFiles, setFiles]
  )

  const focus = useCallback(() => {
    const editor = editorRefs.current[tab]

    editor?.focus()
  }, [tab])

  useEffect(() => {
    editorDidMount({ getFiles, setFiles, focus })
  }, [editorDidMount, getFiles, setFiles, focus])

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
        {files.map((file) => (
          <Tab.Panel
            context={TabsContext}
            key={file.filename}
            id={file.filename}
            alwaysAttachToDOM
          >
            {file.type === 'legacy' ? (
              <LegacyFileBanner onDelete={handleDelete(file)} />
            ) : null}
            <Suspense fallback={RenderLoader()}>
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
                theme={settings.theme || 'light'}
                readonly={
                  readonly || file.type === 'legacy' || file.type === 'readonly'
                }
                commands={[]}
              />
            </Suspense>
          </Tab.Panel>
        ))}
      </div>
    </TabsContext.Provider>
  )
}
