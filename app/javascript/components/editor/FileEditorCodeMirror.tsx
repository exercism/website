import React, {
  useCallback,
  useRef,
  useState,
  useEffect,
  createContext,
  lazy,
  Suspense,
  useContext,
} from 'react'
import { File } from '../types'
import type { Handler } from '../misc/CodeMirror'
import { Tab, TabContext } from '../common/Tab'
import { EditorSettings } from '../editor/types'
import { LegacyFileBanner } from './LegacyFileBanner'
import { RenderLoader } from '@/components/common'
import { useDeepMemo } from '@/hooks/use-deep-memo'
import { EditorFileContext } from './EditorFileContext'
const CodeMirror = lazy(() => import('../misc/CodeMirror'))

export type FileEditorHandle = {
  // getFiles: () => File[]
  // setFiles: (files: File[]) => void
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
  codeMirrorRef,
}: {
  editorDidMount: (editor: FileEditorHandle) => void
  language: string
  onRunTests: () => void
  onSubmit: () => void
  settings: EditorSettings
  files: File[]
  readonly: boolean
  codeMirrorRef: any
}): JSX.Element {
  const { files, setFiles } = useContext(EditorFileContext)
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
  }, [tab])

  const handleDelete = useCallback(
    (fileToDelete: File) => {
      return () => {
        const index = files.findIndex(
          (f) => f.filename === fileToDelete.filename
        )

        if (index === -1) {
          throw 'File not found!'
        }

        if (index === 0) {
          setTab(files[1].filename)
        } else {
          setTab(files[index - 1].filename)
        }

        setFiles(files.filter((f) => f.filename !== fileToDelete.filename))
      }
    },
    [files, setFiles]
  )

  const focus = useCallback(() => {
    const editor = editorRefs.current[tab]

    editor?.focus()
  }, [tab])

  useEffect(() => {
    editorDidMount({ focus })
  }, [editorDidMount, focus])

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
          >
            {file.type === 'legacy' ? (
              <LegacyFileBanner onDelete={handleDelete(file)} />
            ) : null}
            <Suspense fallback={RenderLoader()}>
              <CodeMirror
                ref={codeMirrorRef}
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
