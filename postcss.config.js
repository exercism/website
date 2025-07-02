module.exports = {
  plugins: [
    require('@tailwindcss/postcss'),
    require('postcss-hexrgba'),
    require('postcss-flexbugs-fixes'),
    require('@sector-labs/postcss-inline-class')(),
    // process.env.NODE_ENV === 'production'
    //   ? require('cssnano')({
    //       preset: 'default',
    //     })
    //   : null,
  ],
}
