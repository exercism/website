import { useEffect, useMemo } from 'react'
import { listen } from 'vscode-ws-jsonrpc'
import {
  MonacoLanguageClient,
  CloseAction,
  ErrorAction,
  createConnection,
} from 'monaco-languageclient'
import normalizeUrl from 'normalize-url'
import ReconnectingWebsocket from 'reconnecting-websocket'
import { v4 as uuidv4 } from 'uuid'

export const useLanguageServer = ({ language }: { language: string }): void => {
  const languageServerUrl: string = useMemo(() => {
    const languageServerHost = document.querySelector<HTMLMetaElement>(
      'meta[name="language-server-url"]'
    )?.content

    if (!languageServerHost) {
      throw 'Language server host not found'
    }

    return normalizeUrl(`${languageServerHost}/${language}/${uuidv4()}`)
  }, [language])

  useEffect(() => {
    const webSocket = new ReconnectingWebsocket(languageServerUrl, [], {
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

    return () => {
      webSocket.close()
    }
  }, [language, languageServerUrl])
}
