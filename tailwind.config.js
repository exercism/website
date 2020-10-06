module.exports = {
  future: {
    // removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [],
  theme: {
    borderRadius: {
      none: '0',
      '5': '5px',
      '8': '8px',
      '100': '100px',
    },
    borderWidth: {
      none: '0',
      '1': '1px',
    },
    boxShadow: {
      '1': '0px 4px 24px rgba(79, 114, 205, 0.15)',
      headerBottom: '0px 4px 24px 0px rgba(79, 114, 205, 0.15)',
    },
    colors: {
      transparent: 'transparent',
      current: 'currentColor',
      bgGray: '#FBFCFE',
      lightGray: '#EAECF3',
      textBase: '#343741',
      textLight: '#6D6986',
      borderLight: '#CBC9D9',

      darkBlue: '#6A93FF',
      lightBlue: 'rgba(106, 147, 255, 0.5)',

      darkGreen: '#43B593',
      lightGreen: '#ABDBCC',

      black: '#000',
      white: '#fff',
    },
    fontFamily: {
      body: ['Poppins', 'sans-serif'],
      mono: ['Source Code Pro', 'monospace'],
    },
    fontSize: {
      '14': '14px',
      '16': '16px',
    },
    spacing: {
      '8': '8px',
      '12': '12px',
      '16': '16px',
      '24': '24px',
      '28': '28px',
      '32': '32px',
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
