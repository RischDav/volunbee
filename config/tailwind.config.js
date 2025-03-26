const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
'./app/views/**/*.{html,html.erb,erb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/assets/stylesheets/**/*.css',
  ],
  safelist: [
    {
      pattern: /grid-cols-\d+/,
      variants: ['md', 'lg', 'sm']
    },
    {
      pattern: /gap-\d+/,
    },
    {
      pattern: /(bg|text|border)-.+/,
    },
    {
      pattern: /p-.+/,
    },
    {
      pattern: /m-.+/,
    },
    {
      pattern: /rounded.*/,
    }
  ],
  theme: {
    extend: {
      colors: {
        tumblack: "#000000",
        tumwhite: "#ffffff",
        tumlightblue: "#98C6FE",
        tummediumblue: "#0065BD",
        tumdarkblue: "#003359",
        tumorange: "#E37222",
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}