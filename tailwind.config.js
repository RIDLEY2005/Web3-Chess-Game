// tailwind.config.js
module.exports = {
  purge: ['./src/**/*.{js,jsx,ts,tsx}', './public/index.html'],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        nav: '#00000080',
        navFont: '#FFFFFFA6',
        'modal-bg-color': 'rgba(75, 85, 99,0.20)',
        'play-hand-color': '#1B0D2A',
        'play-comp-color': '#FFFFFF14',
        'dark-purple': '#461464CC',
        'heading-color': '#A5B9F6',
        'btn-purple': '#5A32E6',
        'btn-input': '#1B0D2A',
        'nft-heading': '#34f2f7',
        lightGray: '#6f7886',
        softblue: 'hsl(215, 51%, 70%)',
        cyan: 'hsl(178, 100%, 50%)',
        darkbluemain: 'hsl(217, 54%, 11%)',
        darkbluecard: 'hsl(216, 50%, 16%)',
        darkblueline: 'hsl(215, 32%, 27%)',
      },
      fontFamily: {
        poppins: ['Poppins'],
        montserrat: ['Montserrat'],
        'press-start': ['"Press Start 2P"', 'cursive'],
        out: ['Outfit'],
      },
      backgroundImage: {
        'main-bg': "url('/src/assets/main-background.jpg')",
      },
      maxWidth: {
        '1/2': '50%',
        '1/4': '25%',
        '3/4': '75%',
      },
      minWidth: {
        '1/5': '20%',
        '1/4': '25%',
      },
      maxHeight: {
        '1/2': '50%',
        '1/4': '25%',
        '3/4': '75%',
      },
      borderColor: theme => ({
        DEFAULT: theme('colors.gray.300', 'currentColor'),
        'play-hand-btn': '#5946bc',
      }),
      flex: {
        1: '1 1 0%',
        '3/4': '0.75 0.75 0%',
        '1/4': '0.25 0.25 0%',
        '1/3': '0.33 0.33 0%',
        '2/3': '0.66 0.66 0%',
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
