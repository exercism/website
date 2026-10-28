jest.mock('@/components/editor/ClientSideTestRunner/kernel/Kernel', () => ({
  Kernel: { boot: jest.fn() },
}))

import { KernelManifestEntry } from '@/components/editor/ClientSideTestRunner/types'

type Pool =
  typeof import('@/components/editor/ClientSideTestRunner/kernel/pool')
type Errors =
  typeof import('@/components/editor/ClientSideTestRunner/kernel/errors')

const entry: KernelManifestEntry = {
  type: 'kernel',
  language: 'cpp',
  version: '1',
  timeout: 30,
  kernel: 'http://localhost/kernel/',
  boot: 'http://localhost/boot.json',
  sysroot: 'http://localhost/sysroot.tar',
  testRunner: 'http://localhost/test-runner.tar',
}

// The pool keeps its state in the module, so each test loads a fresh copy.
let pool: Pool
let errors: Errors
let boot: jest.Mock

beforeEach(() => {
  jest.resetModules()
  pool = require('@/components/editor/ClientSideTestRunner/kernel/pool')
  errors = require('@/components/editor/ClientSideTestRunner/kernel/errors')
  boot = require('@/components/editor/ClientSideTestRunner/kernel/Kernel')
    .Kernel.boot
  boot.mockReset()
})

const settle = () => new Promise((resolve) => setTimeout(resolve, 0))

test('a booted spare is handed out and replaced', async () => {
  const kernel = { dispose: jest.fn() }
  boot.mockResolvedValue(kernel)

  pool.prepare(entry)
  await expect(pool.take(entry)).resolves.toBe(kernel)
  expect(boot).toHaveBeenCalledTimes(2)
})

test('a language whose boot failed stops booting kernels', async () => {
  boot.mockRejectedValue(new Error('RuntimeError: unreachable'))

  pool.prepare(entry)
  await settle()

  // The failed spare is still handed to the first run, which reports it.
  await expect(pool.take(entry)).rejects.toThrow('RuntimeError: unreachable')
  expect(boot).toHaveBeenCalledTimes(1)

  // Later runs fail straight away, without another boot.
  await expect(pool.take(entry)).rejects.toBeInstanceOf(errors.KernelError)
  pool.prepare(entry)
  expect(boot).toHaveBeenCalledTimes(1)
})

test('a failure in one language leaves others booting', async () => {
  boot.mockRejectedValueOnce(new Error('boom'))
  pool.prepare(entry)
  await settle()

  boot.mockResolvedValue({ dispose: jest.fn() })
  pool.prepare({ ...entry, language: 'rust', version: '2' })
  expect(boot).toHaveBeenCalledTimes(2)
})
