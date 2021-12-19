#!/usr/bin/env node

const svgrPlugin = require('esbuild-plugin-svgr')
const ImportGlobPlugin = require('esbuild-plugin-import-glob')

/* TODO: For the bugnsag, pass as an ENV var and use something like this:
 * const define = {}

for (const k in process.env) {
  define[`process.env.${k}`] = JSON.stringify(process.env[k])
}
*/

/* TODO: Get a map of all the images (name -> digest name)
 * and pass this into the config to replace the dynamic requires 
 * in Icon/GraphicalIcon which don't work with esbuild */

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
    tsconfig: "./tsconfig.json",
    define: {
      'process.env.BUGSNAG_API_KEY': '"938ae3d231c5455e5c6597de1b1467af"',
    },
    plugins: [svgrPlugin(), ImportGlobPlugin.default()],
  })
  .catch(() => process.exit(1))
