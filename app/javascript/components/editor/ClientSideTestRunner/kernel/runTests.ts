import { Kernel } from './Kernel'
import { take } from './pool'
import { tar } from './tar'
import { KernelManifestEntry, OutputInterface } from '../types'

// The paths the production container uses, so run.sh sees exactly what it sees
// on the server (bin/run-in-docker.sh mounts these two).
const SOLUTION_DIR = '/solution'
const OUTPUT_DIR = '/output'
const RESULTS = `${OUTPUT_DIR}/results.json`
const RUN_SH = '/opt/test-runner/bin/run.sh'

/**
 * Run an exercise's tests inside the kernel.
 *
 * Every track's test runner exposes the same entry point - `bin/run.sh <slug>
 * <solution_dir> <output_dir>`, writing results.json - so this function is the
 * same for every language the kernel can host. The language-specific parts are
 * the sysroot and the runner tarball, and both come from the manifest.
 *
 * That means this is the *same* run.sh, and the same tools, that the server
 * runs. All this does is stage the files, start it, and read back the report.
 */
export async function runTests(
  entry: KernelManifestEntry,
  slug: string,
  files: Record<string, string>,
  signal?: AbortSignal
): Promise<OutputInterface> {
  const kernel = await take(entry)

  try {
    return await run(kernel, entry, slug, files, signal)
  } finally {
    // However this ended - passed, failed, timed out, aborted - the kernel is
    // spent. Nothing is reused across runs.
    kernel.dispose()
  }
}

async function run(
  kernel: Kernel,
  entry: KernelManifestEntry,
  slug: string,
  files: Record<string, string>,
  signal: AbortSignal | undefined
): Promise<OutputInterface> {
  // Stage the solution. Every submitted file goes in as-is, including
  // .meta/config.json and any test helpers: run.sh reads the config to find
  // the test file, and helpers resolve beside it. They go in as one archive
  // so that files in subdirectories get their directories made.
  const staged: Record<string, string> = {
    [`${relative(OUTPUT_DIR)}/.keep`]: '',
  }
  for (const [path, contents] of Object.entries(files)) {
    staged[`${relative(SOLUTION_DIR)}/${path}`] = contents
  }
  await kernel.untar('/', tar(staged))

  const result = await kernel.run([RUN_SH, slug, SOLUTION_DIR, OUTPUT_DIR], {
    cwd: SOLUTION_DIR,
    timeout: entry.timeout * 1000,
    signal,
  })

  let report: string
  try {
    report = await kernel.readFile(RESULTS)
  } catch {
    // run.sh could not parse the test output (a missing test file, a crashed
    // test harness) and never wrote a report. Its own output is the diagnosis.
    throw new Error(
      `${RESULTS} was not written (run.sh exited ${result.status})\n` +
        `${result.stdout}\n${result.stderr}`.trim()
    )
  }

  return JSON.parse(report) as OutputInterface
}

// Archive paths are relative to where the archive is unpacked, which is /.
function relative(path: string): string {
  return path.replace(/^\//, '')
}
