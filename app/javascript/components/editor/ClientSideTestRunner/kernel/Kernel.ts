// One booted kernel, used for exactly one test run.
//
// Nothing here knows about any particular language; the sysroot supplies the
// tools and the manifest says where to get it. The only non-trivial part is
// the session model:
//
//   - run() resolves with a sid; a SessionStarted event brings the stream id.
//     They arrive in either order, so whichever lands second completes the
//     wiring, and output on a not-yet-wired stream is held and replayed.
//   - SessionEnded is the authoritative death signal and carries the exit
//     code; a stream closing is routine.
//   - Nothing we run reads stdin (bats feeds its own heredocs inside the
//     kernel), so streamIn always answers undefined for EOF.
//
// A kernel is disposable and never reused across runs: see pool.ts.

import {
  AbortedRunError,
  KernelError,
  TimeoutError,
  UnsupportedError,
} from './errors'
import {
  BootConfig,
  Interface,
  KernelClient,
  KernelClientConstructor,
  ProcessEvent,
} from './kernelClient'
import { KernelManifestEntry } from '../types'

const decoder = new TextDecoder()

export type RunResult = { status: number; stdout: string; stderr: string }

type Session = {
  out: Uint8Array[]
  err: Uint8Array[]
  ended: Promise<number>
  end: (code: number) => void
}

export class Kernel {
  #client!: KernelClient
  #worker!: Worker
  #disposed = false
  #bySid = new Map<number, Session>()
  #byStream = new Map<number, Session>()
  #pending = new Map<number, Session>() // sid -> session, before its stream arrives
  #starts = new Map<number, number>() // sid -> stream, when the event beat run()
  #held = new Map<number, { out: Uint8Array[]; err: Uint8Array[] }>()

  /** boot.json, kept so callers can report the environment they ran in */
  config!: BootConfig

  private constructor() {}

  /**
   * Boot a kernel and unpack the language's test runner into it.
   *
   * Everything is addressed absolutely from the manifest entry, so no path
   * here is relative to the page. The kernel worker script must nonetheless be
   * same-origin - `new Worker()` rejects a cross-origin URL outright - which is
   * why `/test-runners/` is served under our own origin rather than from the
   * assets host directly.
   */
  static async boot(entry: KernelManifestEntry): Promise<Kernel> {
    if (!globalThis.crossOriginIsolated) {
      throw new UnsupportedError(
        'Client-side test runs need a cross-origin isolated page ' +
          '(Cross-Origin-Opener-Policy: same-origin, ' +
          'Cross-Origin-Embedder-Policy: require-corp).'
      )
    }

    const self = new Kernel()

    // The kernel fetches the sysroot itself, so only boot.json and the runner
    // tarball are pulled here. All three are immutable URLs, so on any boot
    // after the first they come from the browser's cache.
    const [config, testRunner] = await Promise.all([
      fetchJson<BootConfig>(entry.boot),
      fetchBuffer(entry.testRunner),
    ])
    self.config = config

    const Client = await loadClientConstructor(entry.kernel)
    self.#worker = new Worker(new URL('kernel.js', entry.kernel), {
      type: 'module',
      name: 'kernel',
    })
    self.#client = new Client({
      endpoint: self.#worker,
      handlers: self.#handlers(),
    })

    // Subscribe before the first run: a subscription after it could miss the
    // run's SessionStarted. A throw in the callback would end the stream.
    self.#client.processEvents((event) => {
      try {
        self.#onEvent(event)
      } catch (error) {
        console.error('[kernel] event handler failed', error)
      }
    })

    const { env, preload, licence } = self.config
    await self.#client.boot(entry.sysroot, toEnv(env), preload, licence)

    // The sysroot carries the language's tools but not the runner itself, so
    // /opt/test-runner is untarred on top of it. Part of boot rather than of a
    // run: a kernel is only ever handed out ready to use.
    await self.#client.untar('/', testRunner)

    return self
  }

  /** `boot.json`'s env as the `KEY=value` array the kernel takes. */
  get env(): string[] {
    return toEnv(this.config.env)
  }

  writeFile(path: string, contents: string | Uint8Array): void {
    const bytes =
      typeof contents === 'string'
        ? new TextEncoder().encode(contents)
        : contents
    this.#client.writeFile(path, toArrayBuffer(bytes))
  }

  async readFile(path: string): Promise<string> {
    return decoder.decode(await this.#client.readFile(path))
  }

  async run(
    argv: string[],
    options: { cwd: string; timeout: number; signal?: AbortSignal }
  ): Promise<RunResult> {
    const { cwd, timeout, signal } = options
    if (signal?.aborted) {
      throw new AbortedRunError('Run was aborted before it could start')
    }

    const session = makeSession()

    // run() resolves at spawn, not completion. Aborting before it resolves
    // cancels the request; after it, the kernel is disposed of below.
    const request = this.#client.run(argv, this.env, cwd, true)
    signal?.addEventListener('abort', () => request.abort(), { once: true })

    const sid = await request
    this.#bySid.set(sid, session)
    this.#pending.set(sid, session)

    const early = this.#starts.get(sid)
    if (early !== undefined) {
      this.#starts.delete(sid)
      this.#wire(sid, early)
    }

    let timer: ReturnType<typeof setTimeout> | undefined
    const timedOut = new Promise<never>((_, reject) => {
      timer = setTimeout(
        () =>
          reject(
            new TimeoutError(
              `\`${argv.join(' ')}' did not finish within ${timeout / 1000}s`
            )
          ),
        timeout
      )
    })

    try {
      const status = await Promise.race([
        session.ended,
        timedOut,
        onAbort(signal),
      ])
      return { status, stdout: text(session.out), stderr: text(session.err) }
    } catch (error) {
      // A student's solution can loop forever, and asking a kernel that is
      // spinning in a tight loop to tidy up a session is not something to rely
      // on. Killing the worker reclaims everything unconditionally, and since
      // no kernel is ever reused there is nothing left to salvage.
      this.dispose()
      throw error
    } finally {
      clearTimeout(timer)
    }
  }

  /**
   * Tear the kernel down. Idempotent, and safe to call on a kernel that is
   * mid-run - that is the point of it.
   */
  dispose(): void {
    if (this.#disposed) return
    this.#disposed = true

    try {
      this.#client?.close()
    } catch {
      // Closing is best-effort; terminate below is what actually frees it.
    }
    this.#worker?.terminate()

    this.#bySid.clear()
    this.#byStream.clear()
    this.#pending.clear()
    this.#starts.clear()
    this.#held.clear()
  }

  #handlers(): Interface {
    return {
      streamOut: (stream, data) => {
        this.#collect(stream, 'out', data)
      },
      streamErr: (stream, data) => {
        this.#collect(stream, 'err', data)
      },
      // Nothing we run reads stdin.
      streamIn: () => undefined,
      streamClosed: () => {},
    }
  }

  #collect(stream: number, kind: 'out' | 'err', data: ArrayBuffer): void {
    const bytes = new Uint8Array(data)
    const session = this.#byStream.get(stream)
    if (session) {
      session[kind].push(bytes)
      return
    }
    const held = this.#held.get(stream) ?? { out: [], err: [] }
    held[kind].push(bytes)
    this.#held.set(stream, held)
  }

  #onEvent(event: ProcessEvent): void {
    if (event.tag === 'SessionStarted') {
      const { sid, stream_id: stream } = event as {
        sid: number
        stream_id: number
      }
      if (this.#pending.has(sid)) this.#wire(sid, stream)
      else this.#starts.set(sid, stream)
      return
    }
    if (event.tag === 'SessionEnded') {
      const { sid, result } = event as {
        sid: number
        result: { tag: 'Ok'; value: number | undefined } | { tag: 'Err' }
      }
      this.#starts.delete(sid)
      this.#pending.delete(sid)
      const session = this.#bySid.get(sid)
      if (!session) return
      this.#bySid.delete(sid)
      for (const [stream, wired] of this.#byStream) {
        if (wired === session) this.#byStream.delete(stream)
      }
      session.end(exitCode(result))
    }
  }

  #wire(sid: number, stream: number): void {
    const session = this.#pending.get(sid)
    if (!session) return
    this.#pending.delete(sid)
    this.#byStream.set(stream, session)

    const held = this.#held.get(stream)
    if (held) {
      this.#held.delete(stream)
      session.out.push(...held.out)
      session.err.push(...held.err)
    }
  }
}

/**
 * The client is handed a transport it does not create, so the Worker is ours
 * to make - which is what lets us terminate it. The kernel is deployed rather
 * than bundled, so its module is imported from its served path; @vite-ignore
 * keeps bundlers out.
 */
async function loadClientConstructor(
  kernelUrl: string
): Promise<KernelClientConstructor> {
  const clientUrl = new URL('kernel_client.mjs', kernelUrl).href
  try {
    const { KernelClient } = await import(/* @vite-ignore */ clientUrl)
    return KernelClient as KernelClientConstructor
  } catch (error) {
    throw new KernelError(`kernel missing at ${clientUrl}: ${error}`)
  }
}

async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url)
  if (!response.ok) {
    throw new KernelError(`${url} missing (${response.status})`)
  }
  return (await response.json()) as T
}

async function fetchBuffer(url: string): Promise<ArrayBuffer> {
  const response = await fetch(url)
  if (!response.ok) {
    throw new KernelError(`${url} missing (${response.status})`)
  }
  return await response.arrayBuffer()
}

function makeSession(): Session {
  let end!: (code: number) => void
  const ended = new Promise<number>((resolve) => {
    end = resolve
  })
  return { out: [], err: [], ended, end }
}

function toEnv(env: Record<string, string>): string[] {
  return Object.entries(env).map(([key, value]) => `${key}=${value}`)
}

function toArrayBuffer(bytes: Uint8Array): ArrayBuffer {
  return bytes.buffer.slice(
    bytes.byteOffset,
    bytes.byteOffset + bytes.byteLength
  ) as ArrayBuffer
}

function text(chunks: Uint8Array[]): string {
  return chunks.map((chunk) => decoder.decode(chunk, { stream: true })).join('')
}

function exitCode(
  result: { tag: 'Ok'; value: number | undefined } | { tag: 'Err' }
): number {
  // signal-terminated (no exit code) reads as 130
  return result.tag === 'Ok' ? result.value ?? 130 : -1
}

function onAbort(signal: AbortSignal | undefined): Promise<never> {
  return new Promise((_, reject) => {
    if (!signal) return
    signal.addEventListener(
      'abort',
      () =>
        reject(new AbortedRunError('Run was aborted before it could finish')),
      { once: true }
    )
  })
}
