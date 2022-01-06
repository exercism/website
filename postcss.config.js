module.exports = {
  plugins: [
    require('postcss-import'),
    require('tailwindcss/nesting'),
    require('tailwindcss'),
    require('autoprefixer'),
    require('postcss-flexbugs-fixes'),
    process.env.NODE_ENV === 'production' ? require('postcss-minify') : null,
  ],
}

//module.exports = {
//  plugins: [
//    // require('postcss-nesting'),
//    // require('autoprefixer'),

//    //require('postcss-mixins'),
//    require('postcss-import'),
//    require('tailwindcss'),
//    require('postcss-flexbugs-fixes'),
//    require('postcss-preset-env')({
//      autoprefixer: {
//        flexbox: 'no-2009',
//      },
//      features: {
//        'nesting-rules': true,
//      },
//      stage: 3,
//    }),
//  ],
//}
