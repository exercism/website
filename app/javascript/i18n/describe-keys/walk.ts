import fs from 'node:fs/promises'
import path from 'path'

export async function* walk(dir: string): AsyncGenerator<string> {
  for (const e of await fs.readdir(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, e.name)
    if (e.isDirectory()) {
      yield* walk(fullPath)
    } else if (e.isFile() && fullPath.toLowerCase().endsWith('.tsx')) {
      yield fullPath
    }
  }
}
