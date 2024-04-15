declare module 'reconnecting-websocket' {
  interface ReconnectingWebsocket extends WebSocket {
    [key: string]: any
    // eslint-disable-next-line @typescript-eslint/no-misused-new
    new (
      url: string | (() => string),
      protocols?: string | Array<string>,
      options?: {
        maxReconnectionDelay?: number
        minReconnectionDelay?: number
        reconnectionDelayGrowFactor?: number
        connectionTimeout?: number
        maxRetries?: number
        debug?: boolean
      }
    ): ReconnectingWebsocket

    close(
      code?: number,
      reason?: string,
      options?: {
        keepClosed?: boolean
        fastClosed?: boolean
        delay?: number
      }
    ): void
  }

  const ReconnectingWebsocket: ReconnectingWebsocket
  export = ReconnectingWebsocket
}

interface Fonts {
  ready: Promise<void>
}

interface Document {
  fonts: Fonts
}

interface Window {
  turboLoaded: boolean
}

declare module 'nim-codemirror-mode' {
  import { StreamParser } from '@codemirror/stream-parser'
  export const nim: StreamParser<unknown>
}
declare module 'codemirror6-abap' {
  import { StreamParser } from '@codemirror/stream-parser'
  export const abapMode: StreamParser<unknown>
}
declare module 'codemirror-lang-jq' {
  import { LanguageSupport } from '@codemirror/language'
  export const jq: () => LanguageSupport
}

declare module '@exercism/twine2-story-format/src/story' {
  export default class Story {
    constructor(params: any)
    start: (params: any) => any
  }
}

declare module 'highlightjs-sap-abap' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module 'highlightjs-cobol' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module 'highlightjs-bqn' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module 'highlightjs-zig' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module '@gleam-lang/highlight.js-gleam' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module '@ballerina/highlightjs-ballerina' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module 'highlightjs-redbol' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module 'highlightjs-chapel' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module '@exercism/highlightjs-gdscript' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}

declare module 'highlightjs-jq' {
  import { LanguageFn } from 'highlight.js'
  const setup: LanguageFn

  export default setup
}
