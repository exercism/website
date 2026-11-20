jest.mock('@exercism/javascript-browser-test-runner', () => ({
  runTests: jest.fn(),
}))
jest.mock('@/components/editor/ClientSideTestRunner/manifest', () => ({
  lookup: jest.fn(),
}))
jest.mock('@/components/editor/ClientSideTestRunner/kernel/pool', () => ({
  prepare: jest.fn(),
  discard: jest.fn(),
}))

import { runTests as runJs } from '@exercism/javascript-browser-test-runner'
import { runTests } from '@/components/editor/ClientSideTestRunner/clientSideRunner'
import { lookup } from '@/components/editor/ClientSideTestRunner/manifest'
import { AbortedRunError } from '@/components/editor/ClientSideTestRunner/kernel/errors'

const files = { 'hello.js': 'export const hello = () => "Hello"' }

beforeEach(() => jest.clearAllMocks())

test('runs JavaScript with its own runner, passing the signal on', async () => {
  const results = { version: 3, status: 'pass', tests: [] }
  ;(runJs as jest.Mock).mockResolvedValue(results)
  const signal = new AbortController().signal

  await expect(
    runTests('javascript', 'hello-world', files, ['hello.js'], signal)
  ).resolves.toEqual(results)

  expect(runJs).toHaveBeenCalledWith('hello-world', files, ['hello.js'], signal)
  expect(lookup).not.toHaveBeenCalled()
})

test('reports a cancelled JavaScript run as aborted', async () => {
  const controller = new AbortController()
  ;(runJs as jest.Mock).mockImplementation(() => {
    controller.abort()
    return Promise.reject(new Error('aborted inside the package'))
  })

  await expect(
    runTests(
      'javascript',
      'hello-world',
      files,
      ['hello.js'],
      controller.signal
    )
  ).rejects.toBeInstanceOf(AbortedRunError)
})

test('passes on other JavaScript runner errors', async () => {
  const error = new Error('broken')
  ;(runJs as jest.Mock).mockRejectedValue(error)

  await expect(
    runTests('javascript', 'hello-world', files, ['hello.js'])
  ).rejects.toBe(error)
})
