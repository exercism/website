import { File } from '../../types'
import {
  OutputInterface,
  runTests,
} from '@exercism/javascript-browser-test-runner'

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
        const studentFileMap: FileMap = {}
        const studentFileNames: string[] = []

        for (const f of files) {
          if (!f.filename || typeof f.content !== 'string') continue

          studentFileMap[f.filename] = f.content

          if (f.type !== 'readonly') {
            studentFileNames.push(f.filename)
          }
        }

        if (Object.keys(studentFileMap).length === 0) {
          console.warn('studentFileMap is empty in runTestsClientSide')
          return null
        }

        const allFiles: FileMap = {
          ...(config.files || {}),
          ...studentFileMap,
        }

        return await runTests(exerciseSlug, allFiles, studentFileNames)
      }

      default:
        return null
    }
  } catch (error) {
    console.error('runTestsClientSide failed:', error)
    return null
  }
}
