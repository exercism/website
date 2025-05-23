module.exports = {
  mode: 'jit',
  options: {
    // The following extractor is the same as the default of v2, except it includes cut off points for semicolons.
    defaultExtractor: (line) => {
      return [
        ...(line.match(/[^<>"'`;\s]*[^<>"'`;\s:]/g) || []),
        ...(line.match(/[^<>"'`;\s.(){}[\]#=%]*[^<>"'`;\s.(){}[\]#=%:]/g) ||
          []),
      ]
    },
  },

  content: [
    './app/views/**/*.haml',
    './app/helpers/**/*.rb',
    './app/javascript/**/*',
  ],
  theme: {
    extend: {
      screens: {
        max850: { max: '850px' },
        mxl: { min: '1200px' },
        xs: { min: '480px' },
      },
      gridTemplateColumns: {
        // Simple 16 column grid
        '2-auto': 'repeat(2, auto)',
        '3-auto': 'repeat(2, auto)',
      },
      outlineWidth: {
        3: '3px',
      },
      boxShadow: {
        lavenderFocus: '0px 0px 0px 3px rgba(35, 0, 255, 0.3)',
      },
      animation: {
        fadeIn: 'fadeIn 0.2s forwards',
        slideIn: 'slideIn 0.2s forwards',
        slideOut: 'slideOut 0.2s forwards',
        fadeOut: 'fadeOut 0.2s forwards',
        spin: 'spin 2s linear infinite',
        'spin-slow': 'spin 3s linear infinite',
      },
    },
    borderRadius: {
      none: '0',
      3: '3px',
      5: '5px',
      6: '6px',
      8: '8px',
      12: '12px',
      16: '16px',
      24: '24px',
      32: '32px',
      100: '100px',
      circle: '100%',
    },
    borderWidth: {
      0: '0',
      1: '1px',
      2: '2px',
      3: '3px',
      4: '4px',
      6: '6px',
      8: '8px',
    },
    boxShadow: {
      none: 'none',
      buttonS: '0px 4px 8px rgba(var(--shadowColorMain), 0.4)',
      xsZ1: '0px 2px 4px 0px rgba(var(--shadowColorMain), 0.3)',
      xsZ1_dark: '0px 2px 4px #0F0923',
      dark_xsZ1: '0px 2px 4px #0F0923',
      xsZ1v2: '0px 2px 4px 0px rgba(var(--shadowColorMain), 0.15)',
      xsZ1v3: '0px 2px 4px 0px rgba(var(--shadowColorMain), 0.4)',
      sm: 'var(--box-shadow-sm)',
      smZ1: '0px 4px 16px 0px rgba(var(--shadowColorMain), 0.3)',
      base: 'var(--box-shadow-base)',
      baseZ1: '0px 4px 24px 0px rgba(var(--shadowColorMain), 0.3)',
      baseZ1v2: '0px 4px 24px 0px var(--shadowColorSecondary)',
      lg: 'var(--box-shadow-lg)',
      lgv2: '0px 4px 42px rgba(var(--shadowColorMain), 0.6)',
      lgZ1: 'var(--box-shadow-lgZ1)',
      inputSelected: '0px 0px 2px 2px var(--inputBoxShadowColorFocus)',
      keystroke: '0px 1px 0px 1px rgba(var(--shadowColorKeystroke), 0.6)',
      launching: '8px 8px 0px #211E28',

      navDropdown: '0px 6px 28px 4px rgba(var(--shadowColorMain), 0.5)',
    },
    colors: {
      'bootcamp-success-light': '#edfff6',
      'bootcamp-success-dark': '#00bf63',
      'bootcamp-success-text': '#006032',
      'bootcamp-fail-light': '#fff7f7',
      'bootcamp-fail-dark': '#ff5757',
      'bootcamp-fail-text': '#ff5757',
      'bootcamp-purple': '#7029f5',
      'bootcamp-light-purple': '#EFEDFF',
      'bootcamp-very-light-purple': '#f6f5ff',

      /* REPLACE */
      'gray-200': 'rgb(229 231 235)',
      'gray-300': 'rgb(209 213 219)',
      'gray-400': 'rgb(156 163 175)',
      'gray-600': 'rgb(209 213 219)',
      'gray-500': 'rgb(107 114 128)',
      'gray-800': 'rgb(31 41 55)',
      'gray-900': 'rgb(17 24 39)',
      'slate-200': 'rgb(209 213 219)',
      'slate-400': 'rgb(148 163 184)',
      'indigo-300': 'rgb(191 204 255)',
      'blue-100': 'rgb(227 236 255)',
      'blue-300': 'rgb(191 204 255)',
      'blue-400': 'rgb(59 130 246)',
      'blue-500': 'rgb(59 130 246)',
      'blue-700': 'rgb(59 130 246)',
      'red-100': 'rgb(255 236 236)',
      'red-300': 'rgb(255 236 236)',
      'red-500': 'rgb(239 68 68)',
      'red-700': 'rgb(239 68 68)',
      'red-900': 'rgb(107 10 10)',
      'green-100': 'rgb(236 253 245)',
      'green-300': 'rgb(236 253 245)',
      'green-400': 'rgb(0 230 118)',
      'green-500': 'rgb(0 230 118)',
      'green-700': 'rgb(0 128 0)',

      'thick-border-blue': '#F4F6FF',
      'primary-blue': 'rgb(46 87 232)',
      'background-purple': '#FCF9FF',
      'thin-border-blue': '#E2E9FF',
      'jiki-purple': '#7128F5',

      transparent: 'transparent',
      current: 'currentColor',

      /* NEW */
      darkThemeBackgroundColor: 'var(--darkThemeBackgroundColor)',

      backgroundColorA: 'rgb(var(--backgroundColorA-RGB) / <alpha-value>)',
      backgroundColorB: 'var(--backgroundColorB)',
      backgroundColorC: 'var(--backgroundColorC)',
      backgroundColorD: 'var(--backgroundColorD)',
      backgroundColorE: 'var(--backgroundColorE)',
      backgroundColorF: 'var(--backgroundColorF)',
      backgroundColorG: 'var(--backgroundColorG)',
      backgroundColorH: 'var(--backgroundColorH)',
      backgroundColorI: 'var(--backgroundColorI)',
      backgroundColorHoverMenuTrack: 'var(--backgroundColorHoverMenuTrack)',
      borderColor1: 'var(--borderColor1)',
      borderColor3: 'var(--borderColor3)',
      borderColor4: 'var(--borderColor4)',
      borderColor5: 'var(--borderColor5)',
      borderColor6: 'var(--borderColor6)',
      borderColor7: 'var(--borderColor7)',
      borderColor8: 'var(--borderColor8)',
      borderColor9: 'var(--borderColor9)',
      textColor1: 'var(--textColor1)',
      textColor1NoDark: 'var(--textColor1-no-dark)',
      textColor2: 'var(--textColor2)',
      textColor3: 'var(--textColor3)',
      textColor5: 'var(--textColor5)',
      textColor6: 'var(--textColor6)',
      textColor6NoDark: '#5C5589',
      textColor7: 'var(--textColor7)',
      textColor8: 'var(--textColor8)',
      textColor9: 'var(--textColor9)',
      textColor10: 'var(--textColor10)',
      prominentLinkColor: 'var(--c-prominent-link-color)',

      linkColor: 'var(--linkColor)',
      buttonBorderColor1: 'var(--buttonBorderColor1)',
      buttonBorderColor2: 'var(--buttonBorderColor2)',
      inputBackgroundColor: 'var(--inputBackgroundColor)',
      inputBorderColor: 'var(--inputBorderColor)',
      inputBorderColorFocus: 'var(--inputBorderColorFocus)',
      tabBackgroundColorSelected: 'var(--tabBackgroundColorSelected)',
      tabColorSelected: 'var(--tabColorSelected)',
      tabIconColorSelected: 'var(--tabIconColorSelected)',
      tabBorderColorSelected: 'var(--tabBorderColorSelected)',
      successColor: 'var(--successColor)',
      lockedColor: 'var(--lockedColor)',

      paginationCurrentBackgroundColor:
        'var(--paginationCurrentBackgroundColor)',
      paginationCurrentBorderColor: 'var(--paginationCurrentBorderColor)',

      easy: '#5FB268',
      easyLight: '#EFFFF1',

      disabledLight: '#E0DFEA',
      disabledLabel: '#76709F',

      medium: '#A5A256',
      mediumLight: '#F7F5E0',

      hard: '#CB8D6A',
      hardLight: '#F4EBE5',

      unnamed10: '#3D3B45',
      unnamed13: '#33363F',
      unnamed15: '#F0F3F9',
      aliceBlue: '#F0F3F9',
      unnamed16: '#8480A0',
      randomBlue: '#F9F8FF',
      lightGold: '#FFD38F',

      blueViolet: '#9E8EFF',
      darkBlueViolet: '#282339',

      veryDarkGray: '#221E31',
      darkBlueGray: '#211D2F',
      smokeGray: '#26282D',
      bgGray: '#FBFCFE',
      lightGray: '#EAECF3',
      borderLight: '#CBC9D9',
      borderLight2: '#D5D8E4',

      lightBlue: '#2E57E8',
      darkBlue: '#6A93FF',
      veryLightBlue: '#E1EBFF',
      veryLightBlue2: '#E2EBFF',
      evenLighterBlue: '#ECF2FF',
      cornflowerBlue: '#6A93FF',
      wildBlueYonder: '#A7B7D6',
      crayola: '#C8D5EF',
      eerieBlack: '#191525',
      richBlack: '#09080C',

      btnBorder: '#5C5589',
      primaryBtnBorder: '#130B43',
      purple: '#604FCD',
      purpleDimmed: '#604FCD66',
      adaptivePurple: 'var(--colorPurpleToBrightPurple)',
      brightPurple: '#A9A0E4',
      purpleDarkened: '#3B2A93',
      purpleDarker3: '#453A8F',
      anotherPurple: '#604FCD' /* Remove this */,
      russianViolet: '#302b42',
      englishViolet: '#4A475F',
      lightPurpleDarkened: '#f2f0fc',
      gotToLoveAPurple: '#271B72',
      biggerBolderAndMorePurpleThanEver: '#130B43',
      // textColor1
      midnightBlue: '#130B43',
      lightPurple: '#FAFAFF',
      purpleForever: '#5042AD',
      vividPurple: '#7029F5',
      darkPlaceholder: '#9D94DA',
      lightLavender: 'rgba(35, 0, 255, 0.3)',
      lavender: '#d5d8e4',
      purpleHover: '#F2F0FC',

      champagne: '#fff4e3',
      yellowPrompt: '#FFD38F',
      launchingYellow: '#F7B000',
      greenPrompt: '#59D2AE',
      chatGptGreen: '#74aa9d',

      gray: '#A9A6BD',
      // TODO: fix this - change it back to its hex value
      darkGray: 'var(--textColor3)',
      trueDarkGray: '#26282D',

      darkSuccessGreen: '#2E8C70',
      darkGreen: '#43B593',
      mediumGreen: '#B8EADB',
      lightGreen: '#ABDBCC',
      veryLightGreen: 'rgba(79,205,167,0.15)',
      veryLightGreen2: '#E7FDF6',
      limeGreen: '#1FA378',
      healthyGreen: '#00B500',
      seafoamGreen: '#59D2AE',

      tooManyGreens: '#59D2AE',
      literallySoManyGreens: '#4FCDA7',
      soManyGreens: '#228466',
      bgGreen: 'rgba(89, 210, 174, 0.15)',
      everyoneLovesAGreen: '#349F7F',

      orange: '#F69605',
      lightOrange: '#FFF3E1',
      superLightOrange: '#FFFDFA',
      darkRed: '#D03B3B',
      red: '#EB5757',
      lightRed: '#FDEAEA',
      veryLightRed: '#FFEDED',
      veryVeryLightRed: '#FFF4F4',
      youtubeRed: '#D81A1A',
      discordBlue: '#5865F2',
      bgRed: 'rgba(235, 87, 87, 0.15)',
      gold: '#E2CB2D',
      brown: '#47300C',
      lightBrown: '#955D09',

      gradientProgressBarA: '#2200FF',
      gradientProgressBarB: '#9E00FF',

      warning: '#E48900',
      warningBtnBorder: '#573C13',

      // I think this should be called danger, as it is a variant of alert
      alert: '#D85050',
      danger: '#D85050',
      danger_dark: '#F17070',
      bgDanger_dark: '#2F2121',
      alertBtnBorder: '#873333',

      textCAlert: 'var(--textColorCAlert)',
      textCAlertLabel: 'var(--textColorCAlertLabel)',
      bgCAlert: 'var(--backgroundColorCAlert)',

      anotherGold: '#FAE54D',

      muddy: '#6E82AA',
      caution: '#955D09',
      cautionBright: '#F9D59F',
      cautionLabel: '#3E2705',
      color22: 'var(--color22)',

      commonBadge: 'rgb(var(--commonBadge-RGB))',
      commonBadgeFill: '#505359',
      rareBadge: '#DBF0FF',
      rareBadgeFill: '#00144B',
      ultimateBadge: '#F69605',
      ultimateBadgeFill: '#560000',
      legendaryBadge: '#EB5757',
      legendaryBadgeFill: '#4B0000',

      softEmphasis: 'var(--textColorSoftEmphasis)',

      white: '#fff',
      black: '#000',

      fillColorProgress: 'var(--fillColorProgress)',
      backgroundColorNavDropdown: 'var(--backgroundColorNavDropdown)',
    },
    fontFamily: {
      body: 'var(--body-font)',
      mono: ['Source Code Pro', 'monospace'],
    },
    fontSize: {
      12: '12px',
      13: '13px',
      14: '14px',
      15: '15px',
      16: '16px',
      17: '17px',
      18: '18px',
      20: '20px',
      21: '21px',
      22: '22px',
      23: '23px',
      24: '24px',
      25: '25px',
      28: '28px',
      31: '31px',
      32: '32px',
      34: '34px',
      39: '39px',
      40: '40px',
      48: '48px',
      54: '54px',
      64: '64px',
      100: '100%',
    },
    height: {
      auto: 'auto',
      arbitary: '1px',
      fill: '100%',
      full: '100%',
      screen: '100vh',
      32: '32px',
      48: '48px',
      100: '100%',
    },

    lineHeight: {
      none: '1',
      tight: '125%',
      regular: '138%',
      paragraph: '150%',
      code: '160%',
      huge: '170%',

      100: '100%',
      120: '120%',
      130: '130%',
      140: '140%',
      150: '150%',
      160: '160%',
      170: '170%',
      180: '180%',
      190: '190%',
      200: '200%',
    },
    spacing: {
      auto: 'auto',
      0: '0px',
      2: '2px',
      4: '4px',
      6: '6px',
      8: '8px',
      10: '10px',
      12: '12px',
      16: '16px',
      20: '20px',
      24: '24px',
      28: '28px',
      32: '32px',
      36: '36px',
      40: '40px',
      44: '44px',
      48: '48px',
      52: '52px',
      56: '56px',
      60: '60px',
      64: '64px',
      72: '72px',
      80: '80px',
      84: '84px',
      88: '88px',
      96: '96px',
      128: '128px',
      140: '140px',
    },
    width: {
      // Sometimes, elements need to have *some* width set
      // to then respond to flex-grow. This is used for that.
      auto: 'auto',
      arbitary: '1px',
      fill: '100%',
      full: '100%',
      '5-7': '71.4%',
      '1-3': '33.3%',
      '1-2': '50%',
      100: '100%',
      fit: 'fit-content',
      unset: 'unset',
    },
    maxWidth: {
      '1-2': '50%',
    },
    zIndex: {
      '-1': '-1',
      '-2': '-2',
      '-3': '-3',
      '-4': '-4',
      1: '1',
      shadow: '2',
      divider: '5',
      overlay: '10',
      menu: '40',
      dropdown: '50',
      tooltip: '80',
      'tooltip-content': '81',
      modal: '100',
      redirect: '150',
    },
  },
  variants: {
    extend: {
      borderColor: ['focus-within', 'focus', 'hover'],
      backgroundColor: ['focus-within'],
    },
  },
  plugins: [
    [
      'postcss-reuse',
      {
        mode: 'class',
      },
    ],
    function ({ addVariant }) {
      addVariant('child', '& > *'), addVariant('not-last', '&:not(:last-child)')
    },
  ],
  corePlugins: {
    container: false,
  },
}
