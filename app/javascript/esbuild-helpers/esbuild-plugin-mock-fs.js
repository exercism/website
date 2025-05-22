module.exports = {
  name: 'mock-fs',
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
              close: function () {},
              open: function () {},
            };

            Object.defineProperties(fs, {
              close: {
                value: function () {},
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
}
