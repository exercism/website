import { File } from '../../types'
import { runJsTests } from './jsTestRunner'

export function runTestsClientSide(files: File[]) {
  const solutionFile = files[0]

  const fileExtension = solutionFile.filename.split('.').pop()

  switch (fileExtension) {
    case 'js':
      return runJsTests()

    default:
      return null
  }
}
