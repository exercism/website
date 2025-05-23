import { OutputInterface } from '@exercism/javascript-browser-test-runner/src/output'
import { File } from '../../types'
import { runTests } from '@exercism/javascript-browser-test-runner'

type FileMap = Record<string, string>

interface RunTestsClientSideParams {
  trackSlug: string
  exerciseSlug: string
  config?: { files?: FileMap }
  files: File[]
}

export async function runTestsClientSide({
  trackSlug,
  exerciseSlug,
  config = {},
  files,
}: RunTestsClientSideParams): Promise<OutputInterface | null> {
  try {
    if (!trackSlug || !exerciseSlug || !Array.isArray(files)) {
      console.warn('Missing required params in runTestsClientSide')
      return null
    }

    switch (trackSlug) {
      case 'javascript': {
        const studentFileMap: FileMap = Object.fromEntries(
          files
            .filter(
              (f): f is File => !!f.filename && typeof f.content === 'string'
            )
            .map(({ filename, content }) => [filename, content])
        )

        if (Object.keys(studentFileMap).length === 0) {
          console.warn('studentFileMap is empty in runTestsClientSide')
          return null
        }

        const allFiles: FileMap = {
          ...(config.files || {}),
          ...studentFileMap,
        }

        const studentFilenames = Object.keys(studentFileMap)

        return await runTests(exerciseSlug, allFiles, studentFilenames)
      }

      default:
        return null
    }
  } catch (error) {
    console.error('runTestsClientSide failed:', error)
    return null
  }
}
