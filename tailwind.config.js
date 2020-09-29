module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [],
  theme: {
    borderRadius: {
      none: '0',
      '8': '8px',
    },
    boxShadow: {
      '1': '0px 4px 24px rgba(79, 114, 205, 0.15)',
    },
    colors: {
      transparent: 'transparent',
      current: 'currentColor',
      bgGray: '#FBFCFE',
      textLight: '#343741',

      black: '#000',
      white: '#fff',
    },
    fontFamily: {
      body: ['Poppins', 'sans-serif'],
      mono: ['Source Code Pro', 'monospace'],
    },
    fontSize: {
      '16': '16px',
    },
    spacing: {
      '8': '8px',
      '12': '12px',
      '16': '16px',
      '24': '24px',
    },
  },
  variants: {},
  plugins: [],
  corePlugins: {
    container: false,
  },
  // s- for style
  prefix: 's-',
}
