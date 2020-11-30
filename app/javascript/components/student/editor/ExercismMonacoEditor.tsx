import React, { useEffect, useCallback, useMemo, useRef } from 'react'
import MonacoEditor from 'react-monaco-editor'
import * as monacoEditor from 'monaco-editor/esm/vs/editor/editor.api'
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
import { v4 as uuidv4 } from 'uuid'
import { initVimMode, VimMode } from 'monaco-vim'
import { EmacsExtension } from 'monaco-emacs'

export type FileEditorHandle = {
  getFile: () => File
}

type FileEditorProps = {
  file: File
  language: string
  onRunTests: () => void
}

export enum Keybindings {
  DEFAULT = 'default',
  VIM = 'vim',
  EMACS = 'emacs',
}

const SAVE_INTERVAL = 500

export function ExercismMonacoEditor({
  language,
  editorDidMount,
  onRunTests,
  options,
  value,
  theme,
  keybindings,
}: {
  language: string
  editorDidMount: (editor: monacoEditor.editor.IStandaloneCodeEditor) => void
  onRunTests: () => void
  options: monacoEditor.editor.IStandaloneEditorConstructionOptions
  value: string | null | undefined
  theme: string
  keybindings: Keybindings
}) {
  // const languageServerUrl: string = useMemo(() => {
  //   const languageServerHost = document.querySelector<HTMLMetaElement>(
  //     'meta[name="language-server-url"]'
  //   )?.content

  //   if (!languageServerHost) {
  //     throw 'Language server host not found'
  //   }

  //   return normalizeUrl(`${languageServerHost}/${language}/${uuidv4()}`)
  // }, [document, language, uuidv4])

  // useEffect(() => {
  //   const webSocket = new ReconnectingWebsocket(languageServerUrl, [], {
  //     maxReconnectionDelay: 10000,
  //     minReconnectionDelay: 1000,
  //     reconnectionDelayGrowFactor: 1.3,
  //     connectionTimeout: 10000,
  //     maxRetries: Infinity,
  //     debug: false,
  //   })

  //   listen({
  //     webSocket,
  //     onConnection: (connection) => {
  //       const languageClient = new MonacoLanguageClient({
  //         name: 'Language Client',
  //         clientOptions: {
  //           documentSelector: [language],
  //           errorHandler: {
  //             error: () => ErrorAction.Continue,
  //             closed: () => CloseAction.DoNotRestart,
  //           },
  //         },
  //         connectionProvider: {
  //           get: (errorHandler, closeHandler) => {
  //             return Promise.resolve(
  //               createConnection(connection, errorHandler, closeHandler)
  //             )
  //           },
  //         },
  //       })
  //       const disposable = languageClient.start()
  //       connection.onClose(() => disposable.dispose())
  //     },
  //   })

  //   return () => {
  //     webSocket.close()
  //   }
  // }, [languageServerUrl])

  const statusBarRef = useRef<HTMLDivElement | null>(null)
  const editorRef = useRef<monacoEditor.editor.IStandaloneCodeEditor>()
  const keybindingRef = useRef<VimMode | EmacsExtension | null>()

  const handleEditorDidMount = (
    editor: monacoEditor.editor.IStandaloneCodeEditor
  ) => {
    editorRef.current = editor

    editor.addAction({
      id: 'runTests',
      label: 'Run tests',
      keybindings: [monacoEditor.KeyCode.F2],
      run: onRunTests,
    })

    MonacoServices.install(editor)

    editorDidMount(editor)
  }

  useEffect(() => {
    if (!editorRef.current || !statusBarRef.current) {
      return
    }

    keybindingRef.current?.dispose()

    switch (keybindings) {
      case Keybindings.VIM:
        keybindingRef.current = initVimMode(
          editorRef.current,
          statusBarRef.current
        )

        break
      case Keybindings.EMACS:
        const extension = new EmacsExtension(editorRef.current)
        extension.start()

        keybindingRef.current = extension

        break
    }
  }, [editorRef, statusBarRef, keybindings, keybindingRef])

  return (
    <div className="c-file-editor-monaco">
      <MonacoEditor
        language={language}
        editorDidMount={handleEditorDidMount}
        options={options}
        value={value}
        theme={theme}
      />
      <div ref={statusBarRef}></div>
    </div>
  )
}
