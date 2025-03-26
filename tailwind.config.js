const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/views/**/*.{html,html.erb,erb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/assets/stylesheets/**/*.css',
  ],
  safelist: [
  { pattern: /^bg-/ },
  { pattern: /^border/ },  // Catch both border and border-*
  { pattern: /^text-/ },
  { pattern: /^p-/ },    // Padding
  { pattern: /^m-/ },    // Margin
  { pattern: /^mb-/ },   // Margin bottom
  { pattern: /underline/ }, // Underline class
  'font-bold',
  'hover:text-blue-800'
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