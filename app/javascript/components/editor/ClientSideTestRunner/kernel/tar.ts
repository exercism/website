const BLOCK = 512
const NAME_LENGTH = 100

const encoder = new TextEncoder()

/**
 * A ustar archive of `files` (path => contents), with an entry for every
 * directory on the way to each file.
 *
 * The directory entries are the point. The kernel's writeFile does not create
 * a file's missing ancestors, and as a notify it cannot say so, so a solution
 * with `lib/math.jq` in it lost that file silently. untar creates what the
 * archive names, and it reports failure.
 */
export function tar(files: Record<string, string>): ArrayBuffer {
  const blocks: Uint8Array[] = []
  const directories = new Set<string>()

  for (const [path, contents] of Object.entries(files)) {
    const segments = path.split('/')
    for (let depth = 1; depth < segments.length; depth++) {
      const directory = `${segments.slice(0, depth).join('/')}/`
      if (directories.has(directory)) continue

      directories.add(directory)
      blocks.push(header(directory, 0, '5', 0o755))
    }

    const data = encoder.encode(contents)
    blocks.push(header(path, data.length, '0', 0o644), padded(data))
  }

  // The archive ends with two empty blocks.
  blocks.push(new Uint8Array(BLOCK * 2))

  return concat(blocks)
}

function header(
  name: string,
  size: number,
  type: '0' | '5',
  mode: number
): Uint8Array {
  const bytes = new Uint8Array(BLOCK)
  const nameBytes = encoder.encode(name)
  if (nameBytes.length > NAME_LENGTH) {
    throw new Error(`Path too long to stage: ${name}`)
  }

  bytes.set(nameBytes, 0)
  bytes.set(octal(mode, 8), 100)
  bytes.set(octal(0, 8), 108) // uid
  bytes.set(octal(0, 8), 116) // gid
  bytes.set(octal(size, 12), 124)
  bytes.set(octal(0, 12), 136) // mtime
  bytes.set(encoder.encode(type), 156)
  bytes.set(encoder.encode('ustar\0' + '00'), 257)

  // The checksum is the sum of the header's bytes, taken with the checksum
  // field itself reading as spaces.
  bytes.fill(0x20, 148, 156)
  const checksum = bytes.reduce((sum, byte) => sum + byte, 0)
  bytes.set(encoder.encode(`${checksum.toString(8).padStart(6, '0')}\0 `), 148)

  return bytes
}

function octal(value: number, length: number): Uint8Array {
  return encoder.encode(`${value.toString(8).padStart(length - 1, '0')}\0`)
}

function padded(data: Uint8Array): Uint8Array {
  const bytes = new Uint8Array(Math.ceil(data.length / BLOCK) * BLOCK)
  bytes.set(data)
  return bytes
}

function concat(blocks: Uint8Array[]): ArrayBuffer {
  const length = blocks.reduce((sum, block) => sum + block.length, 0)
  const bytes = new Uint8Array(length)

  let offset = 0
  for (const block of blocks) {
    bytes.set(block, offset)
    offset += block.length
  }

  return bytes.buffer
}
