jest.mock('@sentry/react', () => ({ captureException: jest.fn() }))

// The kernel's client is imported from its served URL, so it is mocked under
// that URL.
const mockClient = {
  boot: jest.fn(),
  untar: jest.fn(),
  processEvents: jest.fn(),
  close: jest.fn(),
}
jest.mock(
  'http://localhost/kernel/kernel_client.mjs',
  () => ({ KernelClient: jest.fn(() => mockClient) }),
  { virtual: true }
)

import { TextDecoder } from 'util'
import * as Sentry from '@sentry/react'
import { KernelManifestEntry } from '@/components/editor/ClientSideTestRunner/types'

// jsdom has no TextDecoder, and Kernel.ts makes one as it loads.
Object.assign(globalThis, { TextDecoder })
// eslint-disable-next-line @typescript-eslint/no-var-requires
const {
  Kernel,
} = require('@/components/editor/ClientSideTestRunner/kernel/Kernel')

const entry: KernelManifestEntry = {
  type: 'kernel',
  language: 'cpp',
  version: '19.0.0-1',
  timeout: 30,
  kernel: 'http://localhost/kernel/',
  boot: 'http://localhost/boot.json',
  sysroot: 'http://localhost/sysroot.tar',
  testRunner: 'http://localhost/test-runner.tar',
}

class FakeWorker extends EventTarget {
  static last: FakeWorker
  terminate = jest.fn()
  constructor() {
    super()
    FakeWorker.last = this
  }
}

let done: Promise<void>

beforeEach(() => {
  jest.clearAllMocks()
  Object.assign(globalThis, { crossOriginIsolated: true, Worker: FakeWorker })
  globalThis.fetch = jest.fn(async (url: string) => ({
    ok: true,
    json: async () => ({ env: {} }),
    arrayBuffer: async () => new ArrayBuffer(0),
    url,
  })) as unknown as typeof fetch
  mockClient.processEvents.mockImplementation(() => {
    done = Promise.reject(new Error('the transport failed to start'))
    return { close: jest.fn(), done }
  })
  mockClient.untar.mockResolvedValue(undefined)
})

test('a failed boot terminates its worker and leaves nothing unhandled', async () => {
  const unhandled = jest.fn()
  process.on('unhandledRejection', unhandled)
  mockClient.boot.mockRejectedValue(new Error('the transport failed to start'))

  await expect(Kernel.boot(entry)).rejects.toThrow(
    'the transport failed to start'
  )
  await new Promise((resolve) => setTimeout(resolve, 0))

  expect(FakeWorker.last.terminate).toHaveBeenCalled()
  expect(unhandled).not.toHaveBeenCalled()
  process.off('unhandledRejection', unhandled)
})

test('a crash in the worker is cancelled and reported once', async () => {
  let crash!: () => void
  mockClient.boot.mockImplementation(
    () =>
      new Promise((_, reject) => {
        crash = () => reject(new Error('the transport failed to start'))
      })
  )
  Object.defineProperty(navigator, 'deviceMemory', {
    value: 2,
    configurable: true,
  })

  const booting = Kernel.boot(entry)
  await new Promise((resolve) => setTimeout(resolve, 0))

  const event = new ErrorEvent('error', {
    message: 'Uncaught RuntimeError: unreachable',
    cancelable: true,
  })
  FakeWorker.last.dispatchEvent(event)
  FakeWorker.last.dispatchEvent(
    new ErrorEvent('error', { message: 'again', cancelable: true })
  )
  crash()

  await expect(booting).rejects.toThrow()
  expect(event.defaultPrevented).toBe(true)
  expect(Sentry.captureException).toHaveBeenCalledTimes(1)
  expect(Sentry.captureException).toHaveBeenCalledWith(
    expect.objectContaining({
      message: 'kernel crashed: Uncaught RuntimeError: unreachable',
    }),
    expect.objectContaining({
      tags: {
        language: 'cpp',
        kernel_version: '19.0.0-1',
        device_memory: '2',
      },
    })
  )
})
