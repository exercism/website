#!/usr/bin/env node
const fs = require('fs')
const svgrPlugin = require('esbuild-plugin-svgr')
const ImportGlobPlugin = require('esbuild-plugin-import-glob')

function build() {
  const env = require('./.config/env.json')
  require('esbuild')
    .build({
      entryPoints: [
        './app/javascript/packs/application.tsx',
        './app/javascript/packs/core.tsx',
        './app/javascript/packs/internal.tsx',
      ],
      bundle: true,
      sourcemap: true,
      minify: process.env.NODE_ENV === 'production',
      watch: process.argv.includes('--watch'),
      outdir: '.built-assets',
      tsconfig: './tsconfig.json',
      define: {
        'process.env.BUGSNAG_API_KEY': '"938ae3d231c5455e5c6597de1b1467af"',
        'process.env.WEBSITE_ASSETS_HOST': `"${env['website_assets_host']}"`,
      },
      plugins: [svgrPlugin(), ImportGlobPlugin.default()],
    })
    .catch(() => process.exit(1))
}

const intervalID = setInterval(() => {
  // Wait for the env config file to exists before building
  fs.access('./.config/env.json', fs.constants.F_OK, (err) => {
    if (err) {
      return
    }

    clearInterval(intervalID)
    build()
  })
}, 100)
