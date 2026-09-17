import { File } from '../../types'
import { runTests } from './clientSideRunner'
import { AbortedRunError } from './kernel/errors'
import { OutputInterface } from './types'

export { prefetch, release } from './clientSideRunner'
export type { OutputInterface } from './types'

type FileMap = Record<string, string>

interface RunTestsClientSideParams {
  trackSlug: string
  exerciseSlug: string
  // Null, not just absent, when the exercise has no local test runner config.
  config?: { files?: FileMap } | null
  files: File[]
  signal?: AbortSignal
}

/**
 * Run an exercise's tests in the browser, if this track can.
 *
 * Null means "run this on the server" - because the track has no client-side
 * runner, because something failed to load, or because the run itself broke.
 * The caller submits either way, so a null here costs a student nothing beyond
 * the usual wait.
 */
export async function runTestsClientSide({
  trackSlug,
  exerciseSlug,
  config,
  files,
  signal,
}: RunTestsClientSideParams): Promise<OutputInterface | null> {
  try {
    if (!trackSlug || !exerciseSlug || !Array.isArray(files)) {
      console.warn('Missing required params in runTestsClientSide')
      return null
    }

    const studentFileMap: FileMap = {}
    const studentFileNames: string[] = []

    for (const file of files) {
      if (!file.filename || typeof file.content !== 'string') continue

      studentFileMap[file.filename] = file.content

      if (file.type !== 'readonly') {
        studentFileNames.push(file.filename)
      }
    }

    if (Object.keys(studentFileMap).length === 0) {
      console.warn('studentFileMap is empty in runTestsClientSide')
      return null
    }

    // The exercise's own files first, so a student can only ever overwrite
    // them with their own submission, never remove one.
    const allFiles: FileMap = {
      ...(config?.files || {}),
      ...studentFileMap,
    }

    return await runTests(
      trackSlug,
      exerciseSlug,
      allFiles,
      studentFileNames,
      signal
    )
  } catch (error) {
    // Not a failure: `null` would mean "run it on the server", which cancelling isn't.
    if (error instanceof AbortedRunError) throw error

    console.error('runTestsClientSide failed:', error)
    return null
  }
}
