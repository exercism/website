const fs = require('fs')
const path = require('path')

const src = path.resolve(
  __dirname, // this is scripts/wasm/
  '../../node_modules/@ruby/3.4-wasm-wasi/dist/ruby+stdlib.wasm'
)
const destDir = path.resolve(__dirname, '../../public/wasm/ruby')
const dest = path.join(destDir, 'ruby+stdlib.wasm')

if (!fs.existsSync(destDir)) {
  fs.mkdirSync(destDir, { recursive: true })
}

fs.copyFileSync(src, dest)
console.log('✅ Copied ruby+stdlib.wasm to public/wasm/ruby/')
