#!/usr/bin/env node

setTimeout(() => {
  const fs = require('fs')
  const svgrPlugin = require('esbuild-plugin-svgr')
  const ImportGlobPlugin = require('esbuild-plugin-import-glob')

  // Wait for the env config file to exists before building
  const listener = fs.watchFile('./.config/env.json', () => {
    fs.unwatchFile('./.config/env.json', listener)

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
  })
}, 2000)
