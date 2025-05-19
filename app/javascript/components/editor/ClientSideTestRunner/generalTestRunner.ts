import { OutputInterface } from '@exercism/javascript-browser-test-runner/src/output'
import { File } from '../../types'
import { runTests } from '@exercism/javascript-browser-test-runner/src/index'

type FileMap = Record<string, string>

export async function runTestsClientSide({
  trackSlug,
  exerciseSlug,
  config,
  files,
}: {
  trackSlug: string
  exerciseSlug: string
  config: { files: FileMap }
  files: File[]
}): Promise<OutputInterface | null> {
  const studentFileMap = Object.fromEntries(
    files.map(({ filename, content }) => [filename, content])
  )

  const studentFilenames = Object.keys(studentFileMap)
  const allFiles = { ...config.files, ...studentFileMap }

  switch (trackSlug) {
    case 'javascript':
      return runTests(exerciseSlug, allFiles, studentFilenames)

    default:
      return null
  }
}
