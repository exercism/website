import { execFileSync } from 'child_process'
import { mkdtempSync, readFileSync, writeFileSync } from 'fs'
import { tmpdir } from 'os'
import { join } from 'path'
import { TextEncoder } from 'util'

// jsdom has no TextEncoder, and tar.ts makes one as it loads.
Object.assign(globalThis, { TextEncoder })
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { tar } = require('@/components/editor/ClientSideTestRunner/kernel/tar')

// Unpacked by the system's tar, so this checks the archive against a real
// reader of the format.
function unpack(files: Record<string, string>): string {
  const dir = mkdtempSync(join(tmpdir(), 'tar-test-'))
  const archive = join(dir, 'staged.tar')
  writeFileSync(archive, new Uint8Array(tar(files)))
  execFileSync('tar', ['-xf', archive, '-C', dir])
  return dir
}

test('unpacks files in nested subdirectories', () => {
  const dir = unpack({
    'solution/two-bucket.jq': 'import "lib/math" as Math;',
    'solution/lib/math.jq': 'def gcd: 1;',
    'solution/lib/deep/er.jq': 'def x: "ü";',
    'output/.keep': '',
  })

  expect(readFileSync(join(dir, 'solution/two-bucket.jq'), 'utf8')).toBe(
    'import "lib/math" as Math;'
  )
  expect(readFileSync(join(dir, 'solution/lib/math.jq'), 'utf8')).toBe(
    'def gcd: 1;'
  )
  expect(readFileSync(join(dir, 'solution/lib/deep/er.jq'), 'utf8')).toBe(
    'def x: "ü";'
  )
  expect(readFileSync(join(dir, 'output/.keep'), 'utf8')).toBe('')
})

test('names each directory once, before the files in it', () => {
  const archive = join(mkdtempSync(join(tmpdir(), 'tar-test-')), 'staged.tar')
  writeFileSync(
    archive,
    new Uint8Array(tar({ 'a/b/one': '1', 'a/b/two': '2', 'a/three': '3' }))
  )

  const entries = execFileSync('tar', ['-tf', archive], { encoding: 'utf8' })
  expect(entries.trim().split('\n')).toEqual([
    'a/',
    'a/b/',
    'a/b/one',
    'a/b/two',
    'a/three',
  ])
})

test('contents longer than a block survive', () => {
  const contents = 'x'.repeat(1300)
  const dir = unpack({ 'big.txt': contents })

  expect(readFileSync(join(dir, 'big.txt'), 'utf8')).toBe(contents)
})

test('refuses a path the header cannot hold', () => {
  expect(() => tar({ ['d/'.repeat(60) + 'file']: '' })).toThrow(/too long/)
})
