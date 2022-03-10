#!/usr/bin/env node
const fs = require('fs')
const ImportGlobPlugin = require('esbuild-plugin-import-glob')
const browserslistToEsbuild = require('browserslist-to-esbuild')

function build() {
  const env = require('./.config/env.json')
  require('esbuild')
    .build({
      entryPoints: [
        './app/javascript/packs/application.tsx',
        './app/javascript/packs/core.tsx',
        './app/javascript/packs/internal.tsx',
        './app/javascript/packs/landing.tsx',
        ...(process.env.RAILS_ENV === 'test'
          ? ['./app/javascript/packs/test.tsx']
          : []),
      ],
      bundle: true,
      sourcemap: true,
      format: 'esm',
      splitting: true,
      minify: process.env.NODE_ENV === 'production',
      watch: process.argv.includes('--watch'),
      outdir: '.built-assets',
      tsconfig: './tsconfig.json',
      target: browserslistToEsbuild(),
      define: {
        // TODO: move bugsnag API key into config
        'process.env.BUGSNAG_API_KEY': '"938ae3d231c5455e5c6597de1b1467af"',

        // The || '' part is needed to prevent the value being injected
        // into the code being the literal "null"
        'process.env.WEBSITE_ASSETS_HOST': `"${
          env['website_assets_host'] || ''
        }"`,
      },
      plugins: [ImportGlobPlugin.default()],
    })
    .catch(() => process.exit(1))
}

const intervalID = setInterval(() => {
  // Wait for the env config file to exists before building
  fs.access('app/javascript/.config/env.json', fs.constants.F_OK, (err) => {
    if (err) {
      return
    }

    clearInterval(intervalID)
    build()
  })
}, 100)
