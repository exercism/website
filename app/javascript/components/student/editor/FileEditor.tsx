import React, {
  forwardRef,
  useImperativeHandle,
  useRef,
  useEffect,
  useCallback,
  useState,
} from 'react'
import { File } from '../Editor'
import MonacoEditor from 'react-monaco-editor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'
import { useStorage } from '../../../utils/use-storage'
import { listen, MessageConnection } from 'vscode-ws-jsonrpc'
import {
  MonacoLanguageClient,
  CloseAction,
  ErrorAction,
  MonacoServices,
  createConnection,
} from 'monaco-languageclient'
import normalizeUrl from 'normalize-url'
import ReconnectingWebsocket from 'reconnecting-websocket'

export type FileEditorHandle = {
  getFile: () => File
}

type FileEditorProps = {
  file: File
  language: string
  onRunTests: () => void
}

const SAVE_INTERVAL = 500

export const FileEditor = forwardRef<FileEditorHandle, FileEditorProps>(
  ({ file, language, onRunTests }, ref) => {
    const [theme, setTheme] = useState('vs')
    const [options, setOptions] = useState<
      monacoEditor.editor.IStandaloneEditorConstructionOptions
    >({
      minimap: { enabled: false },
      wordWrap: 'on',
      glyphMargin: true,
      lightbulb: { enabled: true },
    })
    const [content, setContent] = useStorage<string>(
      `${file.filename}-editor-content`,
      file.content
    )
    const editorRef = useRef<monacoEditor.editor.IStandaloneCodeEditor>()
    const editorDidMount = useCallback(
      (editor) => {
        editor.addAction({
          id: 'runTests',
          label: 'Run tests',
          keybindings: [monacoEditor.KeyCode.F2],
          run: onRunTests,
        })

        MonacoServices.install(editor)
        const url = normalizeUrl(`ws://localhost:3000/${language}`)
        const webSocket = new ReconnectingWebsocket(url, [], {
          maxReconnectionDelay: 10000,
          minReconnectionDelay: 1000,
          reconnectionDelayGrowFactor: 1.3,
          connectionTimeout: 10000,
          maxRetries: Infinity,
          debug: false,
        })
        listen({
          webSocket,
          onConnection: (connection) => {
            const languageClient = new MonacoLanguageClient({
              name: 'Language Client',
              clientOptions: {
                documentSelector: [language],
                errorHandler: {
                  error: () => ErrorAction.Continue,
                  closed: () => CloseAction.DoNotRestart,
                },
              },
              connectionProvider: {
                get: (errorHandler, closeHandler) => {
                  return Promise.resolve(
                    createConnection(connection, errorHandler, closeHandler)
                  )
                },
              },
            })
            const disposable = languageClient.start()
            connection.onClose(() => disposable.dispose())
          },
        })
        editorRef.current = editor
      },
      [editorRef]
    )
    const handleWrapChange = useCallback(
      (e) => {
        setOptions({ ...options, wordWrap: e.target.value })
      },
      [setOptions]
    )
    const handleThemeChange = useCallback(
      (e) => {
        setTheme(e.target.value)
      },
      [setTheme]
    )
    const revertContent = useCallback(
      (e) => {
        setContent(file.content)
      },
      [setContent, file]
    )

    useImperativeHandle(ref, () => ({
      getFile() {
        return {
          filename: file.filename,
          content: editorRef.current?.getValue() || '',
        }
      },
    }))

    useEffect(() => {
      const interval = setInterval(() => {
        setContent(editorRef.current?.getValue())
      }, SAVE_INTERVAL)

      return () => clearInterval(interval)
    }, [])

    return (
      <div>
        <label htmlFor={`${file.filename}-editor-wrap`}>Wrap</label>
        <select
          id={`${file.filename}-editor-wrap`}
          value={options.wordWrap}
          onChange={handleWrapChange}
        >
          <option value="off">Off</option>
          <option value="on">On</option>
        </select>
        <label htmlFor={`${file.filename}-editor-theme`}>Theme</label>
        <select
          id={`${file.filename}-editor-theme`}
          value={theme}
          onChange={handleThemeChange}
        >
          <option value="vs">Light</option>
          <option value="vs-dark">Dark</option>
        </select>
        {content !== file.content && (
          <button onClick={revertContent} type="button">
            Revert to last run code
          </button>
        )}
        <MonacoEditor
          key={file.filename}
          width="800"
          height="600"
          language={language}
          editorDidMount={editorDidMount}
          options={options}
          value={content}
          theme={theme}
        />
      </div>
    )
  }
)
