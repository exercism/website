module.exports = {
  plugins: [
    require('postcss-import'),
    require('tailwindcss/nesting'),
    require('tailwindcss'),
    require('postcss-hexrgba'),
    require('autoprefixer'),
    require('postcss-flexbugs-fixes'),
    process.env.NODE_ENV === 'production'
      ? require('cssnano')({
          preset: 'default',
        })
      : null,
  ],
}
