module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
    keyframes: {
      'fade-in-fast': {
        '0%': { opacity: 0, transform: 'translateY(-10px)' },
        '100%': { opacity: 1, transform: 'translateY(0)' },
      }
    },
    animation: {
      'fade-in-fast': 'fade-in-fast 0.3s ease-out',
    }
  },
    extend: {},
  },
  plugins: [],
}
