/**
 * The shape of the kernel's generated client.
 *
 * The kernel is a versioned artifact fetched at runtime from the manifest, so
 * its client is imported dynamically and cannot be typed from a package. These
 * are hand-mirrored from the `kernel_client.d.ts` it ships with; they describe
 * only what we call.
 */
export type Licence = { hostname: string; signature: string }

type ExitResult =
  | { tag: 'Ok'; value: number | undefined }
  | { tag: 'Err'; value: string }

export type ProcessEvent =
  | { tag: 'SessionStarted'; sid: number; stream_id: number }
  | { tag: 'SessionEnded'; sid: number; result: ExitResult }
  | { tag: string; sid: number }

export type Request<T> = Promise<T> & { abort(): void }

export interface Subscription {
  close(): void
  done: Promise<void>
}

/** The handlers the kernel calls back into. Every one is required. */
export interface Interface {
  streamOut(stream: number, data: ArrayBuffer): void | Promise<void>
  streamErr(stream: number, data: ArrayBuffer): void | Promise<void>
  streamIn(
    stream: number
  ): (ArrayBuffer | undefined) | Promise<ArrayBuffer | undefined>
  streamClosed(stream: number): void
}

export interface KernelClient {
  readFile(path: string): Request<ArrayBuffer>
  boot(
    sysroot: string,
    env: string[],
    preload: string[],
    licence?: Licence[]
  ): Request<void>
  untar(path: string, data: ArrayBuffer): Request<void>
  run(
    argv: string[],
    env: string[],
    cwd: string,
    piped: boolean
  ): Request<number>
  hangup(sid: number): void
  processEvents(callback: (item: ProcessEvent) => void): Subscription
  close(): void
}

export type KernelClientConstructor = new (options: {
  endpoint: Worker
  handlers: Interface
}) => KernelClient

/** The kernel's boot.json, served beside sysroot.tar. */
export type BootConfig = {
  env: Record<string, string>
  preload: string[]
  licence?: Licence[]
}
