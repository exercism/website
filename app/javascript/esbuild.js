#!/usr/bin/env node
const fs = require('fs')
const ImportGlobPlugin = require('esbuild-plugin-import-glob')
const {
  nodeModulesPolyfillPlugin,
} = require('esbuild-plugins-node-modules-polyfill')

function build() {
  const env = require('./.config/env.json')
  require('esbuild')
    .build({
      entryPoints: [
        './app/javascript/packs/application.tsx',
        './app/javascript/packs/core.tsx',
        './app/javascript/packs/internal.tsx',
        './app/javascript/packs/landing.tsx',
        './app/javascript/packs/courses.tsx',
        './app/javascript/packs/bootcamp-js.tsx',
        ...(process.env.RAILS_ENV === 'test'
          ? ['./app/javascript/packs/test.tsx']
          : []),
      ],
      bundle: true,
      sourcemap: true,
      format: 'esm',
      // chunkNames: '[name]-[hash]-1',
      splitting: true,
      minify: process.env.NODE_ENV === 'production',
      watch: process.argv.includes('--watch'),
      outdir: '.built-assets',
      tsconfig: './tsconfig.json',
      target: 'es2022',
      inject: ['./app/javascript/esbuild-shim.js'],
      define: {
        // TODO: move bugsnag API key into config
        'process.env.BUGSNAG_API_KEY': '"938ae3d231c5455e5c6597de1b1467af"',

        // The || '' part is needed to prevent the value being injected
        // into the code being the literal "null"
        'process.env.WEBSITE_ASSETS_HOST': `"${
          env['website_assets_host'] || ''
        }"`,
      },
      plugins: [
        ImportGlobPlugin.default(),
        nodeModulesPolyfillPlugin(),
        {
          name: 'mock-modules',
          setup(build) {
            build.onResolve({ filter: /^graceful-fs$/ }, () => {
              return { path: 'graceful-fs', namespace: 'mock-module' }
            })
            build.onLoad({ filter: /.*/, namespace: 'mock-module' }, (args) => {
              if (args.path === 'graceful-fs') {
                return {
                  contents: `
                    const fs = {
                      readFileSync: () => '',
                      writeFileSync: () => {},
                      existsSync: () => false,
                      close: function() {},
                      open: function() {},
                    };
                    
                    Object.defineProperties(fs, {
                      close: { 
                        value: function() {}, 
                        writable: true, 
                        configurable: true 
                      }
                    });
                    
                    module.exports = fs;
                  `,
                  loader: 'js',
                }
              }
            })
          },
        },
      ],
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
