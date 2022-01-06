#!/usr/bin/env node
const svgrPlugin = require('esbuild-plugin-svgr')
const ImportGlobPlugin = require('esbuild-plugin-import-glob')
const config = require('./config/config.json')

require('esbuild')
  .build({
    entryPoints: [
      './app/javascript/packs/application.tsx',
      './app/javascript/packs/core.tsx',
      './app/javascript/packs/internal.tsx',
    ],
    bundle: true,
    sourcemap: true,
    watch: process.argv.includes('--watch'),
    outdir: '.built-assets',
    tsconfig: './tsconfig.json',
    define: {
      'process.env.BUGSNAG_API_KEY': '"938ae3d231c5455e5c6597de1b1467af"',
      'process.env.WEBSITE_ASSETS_HOST': `"${config['website_assets_host']}"`,
    },
    plugins: [svgrPlugin(), ImportGlobPlugin.default()],
  })
  .catch(() => process.exit(1))
