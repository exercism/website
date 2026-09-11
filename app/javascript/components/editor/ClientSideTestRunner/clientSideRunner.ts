import { lookup } from './manifest'
import { prepare, discard } from './kernel/pool'
import { OutputInterface } from './types'

/**
 * Running an exercise's tests in the browser, for the tracks that can.
 *
 * Two mechanisms sit behind this. JavaScript runs in a worker from an npm
 * package, registered in packs/application.tsx. Everything else runs on a wasm
 * kernel: a real Linux userland in which we execute the track's own
 * `bin/run.sh`, exactly as the server does. Which one - and which version - is
 * the manifest's answer, not this file's.
 *
 * Every entry point here returns null rather than throwing when a language
 * cannot run client-side. That is the normal case, not a failure: the caller
 * falls back to a server-side run, which is always available.
 */
export async function runTests(
  language: string,
  slug: string,
  files: Record<string, string>,
  userPaths: string[],
  signal?: AbortSignal
): Promise<OutputInterface | null> {
  // The JavaScript runner predates the manifest and resolves its own worker,
  // so it is dispatched by name. Tracks added since are manifest-driven.
  if (language === 'javascript') {
    const { runTests: runJs } = await import(
      '@exercism/javascript-browser-test-runner'
    )
    return (await runJs(slug, files, userPaths)) as OutputInterface
  }

  const entry = await lookup(language)
  if (!entry) return null

  const { runTests: runOnKernel } = await import('./kernel/runTests')
  return await runOnKernel(entry, slug, files, signal)
}

/**
 * Start loading what this language needs, if anything.
 *
 * Called when the editor mounts. The kernel is several megabytes and takes
 * real time to unpack, so leaving it until the student clicks "Run tests"
 * would put that cost in front of the thing they are waiting for. Doing it
 * here means it happens while they are reading the exercise.
 *
 * Never throws and returns nothing: a failure here just means the first run
 * boots on demand, or falls back to the server.
 */
export async function prefetch(language: string): Promise<void> {
  if (language === 'javascript') return

  try {
    const entry = await lookup(language)
    if (entry) prepare(entry)
  } catch {
    // Best effort by design.
  }
}

/** Release anything held for a language. Called when the editor unmounts. */
export function release(): void {
  discard()
}
