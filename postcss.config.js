module.exports = {
  plugins: [
    //require('postcss-mixins'),
    require('postcss-import'),
    require('tailwindcss'),
    require('postcss-flexbugs-fixes'),
    require('postcss-preset-env')({
      autoprefixer: {
        flexbox: 'no-2009',
      },
      features: {
        'nesting-rules': true,
      },
      stage: 3,
    }),
  ],
}
