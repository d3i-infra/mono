const plugin = require('tailwindcss/plugin')

module.exports = {
  purge: [
    "../../**/*.html.eex",
    "../../**/*.html.leex",
    "../../**/*.ex",
    "./js/**/*.js",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    boxShadow: {
      top4px: 'inset 0 4px 0 0 rgba(0, 0, 0, 0.15)',
      top2px: 'inset 0 2px 0 0 rgba(0, 0, 0, 0.15)',
      '2xl': '0 5px 20px 0px rgba(0, 0, 0, 0.20)',
    },
    colors: {
      primary: '#4272EF',
      primarylight: '#E3EAFD',
      secondary: '#FF5E5E',
      tertiary: '#FFCF60',
      success: '#6FCA37',
      successlight: '#EBFFDF',
      warning: '#F28D15',
      warninglight: '#FFEFDC',
      delete: '#DB1E1E',
      deletelight: '#FFECEC',
      black: '#000000',
      grey1: '#222222',
      grey2: '#999999',
      grey3: '#CCCCCC',
      grey4: '#EEEEEE',
      grey5: '#F6F6F6',
      grey6: '#FAFAFA',
      white: '#FFFFFF',
      apple: '#000000',
      google: '#EA4335',
      surfconext: '#4DB2CF',
    },
    extend: {
      transitionDuration: {
        '2000': '2000ms',
      },
      spacing: {
        "1px" : "1px",
        "2px" : "2px",
        "3px" : "3px",
        "5px" : "5px",
        "6px" : "6px",
        "7px" : "7px",
        "9px" : "9px",
        "10px" : "10px",
        "11px" : "11px",
        "13px" : "13px",
        "14px" : "14px",
        "15px" : "15px",
        "17px" : "17px",
        "18px" : "18px",
        "19px" : "19px",
        "48px" : "48px",
        "44px" : "44px",
        "84px" : "84px",
        "desktop-menu-width" : "256px",
        "mobile-menu-width" : "304px",
      },
      width: {
        "sidebar" : "68px",
        "main-left" : "56px",
        "logo" : "23px",
        "logo-sm" : "48px",
        "illustration" : "188px",
        "illustration-sm" : "320px",
        "illustration-md" : "398px",
        "illustration-lg" : "696px",
        "form" : "400px",
        "card": "376px",
        "image-preview": "200px",
        "image-preview-circle": "150px",
        "popup-md": "730px",
        "popup-lg": "1228px",
        "button-sm": "14px",
      },
        height: {
        "topbar" : "64px",
        "topbar-sm" : "96px",
        "topbar-lg" : "128px",
        "footer" : "48px",
        "footer-sm" : "64px",
        "footer-lg" : "96px",
        "header1" : "100px",
        "header1-sm" : "170px",
        "header1-lg" : "370px",
        "header2" : "50px",
        "header2-sm" : "90px",
        "header2-lg" : "183px",
        "logo" : "32px",
        "logo-sm" : "48px",
        "image-header": "375px",
        "image-header-sm": "500px",
        "image-card": "200px",
        "image-preview": "150px",
        "image-preview-circle": "150px",
        "campaign-banner": "224px",
        "button-sm": "14px",
      },
      fontFamily: {
        'title0': ['Finador-Black', 'sans-serif'],
        'title1': ['Finador-Black', 'sans-serif'],
        'title2': ['Finador-Black', 'sans-serif'],
        'title3': ['Finador-Black', 'sans-serif'],
        'title4': ['Finador-Bold', 'sans-serif'],
        'title5': ['Finador-Bold', 'sans-serif'],
        'title6': ['Finador-Bold', 'sans-serif'],
        'caption': ['Finador-Medium', 'sans-serif'],
        'link': ['Finador-medium', 'sans-serif'],
        'subhead': ['Finador-Regular', 'sans-serif'],
        'button': ['Finador-Bold', 'sans-serif'],
        'intro': ['Finador-Medium', 'sans-serif'],
        'label': ['Finador-Bold', 'sans-serif'],
        'body': ['Finador-Light', 'sans-serif'],
      },
      fontSize: {
        "title0": ['64px', '68px'],
        "title1": ['50px', '55px'],
        "title2": ['40px', '44px'],
        "title3": ['32px', '38px'],
        "title4": ['32px', '32px'],
        "title5": ['24px', '26px'],
        "title6": ['20px', '22px'],
        "caption": ['14px', '18px'],
        "subhead": ['20px', '20px'],
        "label": ['16px', '16px'],
        "button": ['18px', '18px'],
        "intro": ['20px', '30px'],
        "introdesktop": ['24px', '36px'],
        "bodylarge": ['24px', '36px'],
        "bodymedium": ['20px', '30px'],
        "bodysmall": ['16px', '24px'],
        "bodylinklarge": ['24px', '36px'],
        "bodylinkmedium": ['30px', '30px'],
        "link": ['16px', '24px'],
      },
      maxWidth: {
        "card": "376px",
        "form": "400px"
      },
      maxHeight: {
        "header1": "376px",
        "form": "400px"
      },
    },
  },
  variants: {
    extend: {
      borderColor: ['active', 'hover'],
      borderWidth: ['active', 'hover'],
      ringColor: ['hover'],
      ringWidth: ['hover'],
      ringOpacity: ['hover'],
      ringOffsetColor: ['hover'],
      ringOffsetWidth: ['hover'],
      opacity: ['active'],
      padding: ['active'],
      boxShadow: ['active'],
    },
  },
  plugins: [
    plugin(function({ addUtilities }) {
      const newUtilities = {
        '.scrollbar-hide': {
          /* Firefox */
          'scrollbar-width': 'thin',

          /* Safari and Chrome */
          '&::-webkit-scrollbar': {
            display: 'none'
          }
        }
      }
      addUtilities(newUtilities)
    })
  ],
}