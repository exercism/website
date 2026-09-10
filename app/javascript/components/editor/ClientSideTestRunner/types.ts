/**
 * The test-runner interface, v3.
 * https://exercism.org/docs/building/tooling/test-runners/interface
 *
 * This is what a run resolves to, whoever produced it: the JavaScript runner
 * builds it in a worker, the kernel runners read it out of the results.json
 * their `bin/run.sh` writes. It goes to the server as-is.
 */
export interface OutputInterface {
  version: 3
  status: 'pass' | 'fail' | 'error'
  message?: string
  tests: OutputTestInterface[]
  'test-environment'?: Record<string, string>
}

export interface OutputTestInterface {
  name: string
  status: 'pass' | 'fail' | 'error'
  message?: string
  output?: string
  test_code: string
  task_id?: string
}

/**
 * A language's entry in the published manifest, fetched from
 * `/test-runners/<language>/latest.json`.
 *
 * Everything it points at is immutable and content-addressed, so the entry
 * itself is the only thing that ever changes. That means switching a language
 * to a new runner - or rolling one back - is an edit to one small JSON file,
 * with no deploy here.
 */
export type ManifestEntry = KernelManifestEntry

export type KernelManifestEntry = {
  type: 'kernel'
  /** Identifies the language build these artifacts came from. */
  version: string
  /** Seconds a single test run may take before the worker is killed. */
  timeout: number
  /** Directory holding kernel.js, kernel_client.mjs and kernel_bg.wasm. */
  kernel: string
  boot: string
  sysroot: string
  testRunner: string
}
