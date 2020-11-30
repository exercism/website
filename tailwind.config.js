module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    // purgeLayersByDefault: true,
  },
  purge: [
    './app/views/**/*.haml',
    './app/helpers/**/*.rb',
    './app/css/**/*.css',
    './app/javascript/**/*',
  ],
  theme: {
    borderRadius: {
      none: '0',
      '3': '3px',
      '5': '5px',
      '8': '8px',
      '12': '12px',
      '100': '100px',
      circle: '100%',
    },
    borderWidth: {
      none: '0',
      '1': '1px',
      '2': '2px',
      '3': '3px',
    },
    boxShadow: {
      sm: '0px 4px 16px 0px rgb(79, 114, 205, 0.1)',
      base: '0px 4px 24px 0px rgba(79, 114, 205, 0.15)',
      lg: '0px 4px 42px 0px rgba(79, 114, 205, 0.15)',
    },
    colors: {
      unnamed15: '#F0F3F9',
      unnamed16: '#8480A0',
      randomBlue: '#F9F8FF',

      transparent: 'transparent',
      current: 'currentColor',
      bgGray: '#FBFCFE',
      lightGray: '#EAECF3',
      textBase: '#343741',
      textLight: '#6D6986',
      borderLight: '#CBC9D9',

      lightBlue: '#2E57E8',
      darkBlue: '#6A93FF',
      veryLightBlue: '#E1EBFF',

      purple: 'rgba(103, 93, 172, 1)',
      lightPurple: '#B0A8E3',
      anotherPurple: '#604FCD',

      gray: '#A9A6BD',
      darkGray: '#26282D',

      darkGreen: '#43B593',
      mediumGreen: '#B8EADB',
      lightGreen: '#ABDBCC',
      tooManyGreens: '#59D2AE',

      orange: '#F69605',
      lightOrange: '#FFF3E1',
      red: '#EB5757',

      black: '#000',
      white: '#fff',
    },
    fontFamily: {
      body: ['Poppins', 'sans-serif'],
      mono: ['Source Code Pro', 'monospace'],
    },
    fontSize: {
      '13': '13px',
      '14': '14px',
      '15': '15px',
      '16': '16px',
      '18': '18px',
      '20': '20px',
      '22': '22px',
      '24': '24px',
      '25': '25px',
      '31': '31px',
      '40': '40px',
    },
    height: {
      '48': '48px',
    },
    lineHeight: {
      none: '1',
      tight: '125%',
      regular: '138%',
      paragraph: '150%',
      code: '160%',
      huge: '170%',
    },
    spacing: {
      '4': '4px',
      '6': '6px',
      '8': '8px',
      '12': '12px',
      '16': '16px',
      '20': '20px',
      '24': '24px',
      '28': '28px',
      '32': '32px',
      '36': '36px',
      '40': '40px',
      '48': '48px',
      '56': '56px',
      '64': '64px',
      '80': '80px',
      spacedColumns: '70px',
    },
    width: {
      // Sometimes, elements need to have *some* width set
      // to then respond to flex-grow. This is used for that.
      auto: 'auto',
      arbitary: '1px',
      '5-7': '41.6%',
      '1-3': '33.3%',
      '1-2': '50%',
      '100': '100%',
    },
    zIndex: {
      '-1': '-1',
      '-2': '-2',
      '-3': '-3',
      '-4': '-4',
    },
  },
  variants: {},
  plugins: [],
  corePlugins: {
    container: false,
  },
  // s- for style
  prefix: 'tw-',
}
