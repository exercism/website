#!/usr/bin/env node
console.log('yay')
const svgrPlugin = require('esbuild-plugin-svgr')
const ImportGlobPlugin = require('esbuild-plugin-import-glob')

/* TODO: For the bugnsag, pass as an ENV var and use something like this:
 * const define = {}

for (const k in process.env) {
  define[`process.env.${k}`] = JSON.stringify(process.env[k])
}
*/

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
    outdir: '.built-assets',
    tsconfig: './tsconfig.json',
    define: {
      'process.env.BUGSNAG_API_KEY': '"938ae3d231c5455e5c6597de1b1467af"',
      'process.env.WEBSITE_ICONS_HOST': `"${config['website_icons_host']}"`,
      'process.env.WEBSITE_ASSETS_HOST': `"${config['website_assets_host']}"`,
    },
    plugins: [svgrPlugin(), ImportGlobPlugin.default()],
  })
  .catch(() => process.exit(1))
