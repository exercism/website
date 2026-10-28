// A one-deep pool of booted, unused kernels.
//
// Every test run gets its own kernel, and that kernel is destroyed afterwards.
// A student's solution is untrusted code: it can loop forever, and whatever it
// leaves behind in /solution must not be visible to the next run. Terminating
// the worker guarantees both, without depending on a kernel that may be wedged
// to cooperate in its own cleanup.
//
// Booting is not cheap - a multi-megabyte sysroot to unpack, then the runner
// tarball on top - so doing it between clicking "Run tests" and seeing output
// would put the cost exactly where it hurts. Instead one spare is kept warm:
// prepared when the editor mounts, and replaced as soon as one is taken. The
// student waits for a boot only if they run tests twice in quick succession.

import { Kernel } from './Kernel'
import { KernelError } from './errors'
import { KernelManifestEntry } from '../types'

type Spare = { entry: KernelManifestEntry; kernel: Promise<Kernel> }

let spare: Spare | null = null

// Languages whose kernel has failed to boot in this page. A device that cannot
// boot a kernel once (too little memory, say) will almost always fail again,
// and each attempt downloads and unpacks the whole sysroot first. So after one
// failure the language stops booting kernels, and its runs go to the server.
const failed = new Set<string>()

/**
 * Start booting a spare if there isn't already one for this language.
 *
 * Safe to call repeatedly and safe to ignore: it never throws. A failed boot
 * is reported by `take`, which hands over the rejected spare.
 */
export function prepare(entry: KernelManifestEntry): void {
  if (failed.has(entry.language)) return
  if (spare && spare.entry.version === entry.version) return

  // A published change to the language means the warm one is stale.
  discard()
  spare = { entry, kernel: boot(entry) }
}

/**
 * A kernel ready to run, and a fresh spare started in its place.
 *
 * The caller owns what it gets back and must `dispose()` it when the run ends,
 * however it ends.
 */
export function take(entry: KernelManifestEntry): Promise<Kernel> {
  const warm = spare && spare.entry.version === entry.version ? spare : null
  spare = null

  if (!warm && failed.has(entry.language)) {
    return Promise.reject(
      new KernelError(`The ${entry.language} kernel already failed to boot`)
    )
  }

  const kernel = warm ? warm.kernel : boot(entry)

  // Start the replacement now rather than after the run finishes, so it boots
  // while the student's tests are running.
  prepare(entry)

  return kernel
}

/** Throw away the warm spare, if any. */
export function discard(): void {
  const stale = spare
  spare = null
  stale?.kernel.then(
    (kernel) => kernel.dispose(),
    () => {}
  )
}

function boot(entry: KernelManifestEntry): Promise<Kernel> {
  const booting = Kernel.boot(entry)
  // Nothing awaits a spare until it is taken, so without this handler a boot
  // failure would surface as an unhandled rejection. The handler also records
  // the failure. The rejection is preserved for whoever does take the spare.
  booting.catch(() => failed.add(entry.language))
  return booting
}
