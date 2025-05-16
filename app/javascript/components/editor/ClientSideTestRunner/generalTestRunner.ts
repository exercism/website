import { File } from '../../types'
import { runJsTests } from './jsTestRunner'
import { runRubyTests } from './rubyTestRunner'

export async function runTestsClientSide(files: File[]) {
  const solutionFile = files[0]

  const fileExtension = solutionFile.filename.split('.').pop()

  switch (fileExtension) {
    case 'js':
      return runJsTests()

    case 'rb':
      return await runRubyTests()

    default:
      return null
  }
}
