const defaultTheme = require('tailwindcss/defaultTheme')



module.exports = {
  darkMode: false,
  content: [
      './app/views/**/*.{erb,html, html.erb}',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js',
      './app/components/**/*.{erb,html,rb}'
  ],
  safelist: [
  //{ pattern: /^bg-/ },
  //{ pattern: /^border/ },  // Catch both border and border-*
  //{ pattern: /^text-/ },
  //{ pattern: /^p-/ },    // Padding
  //{ pattern: /^m-/ },    // Margin
  //{ pattern: /^mb-/ },   // Margin bottom
  //{ pattern: /underline/ }, // Underline class
  //'grid-cols-2',
  //'grid-cols-3',
  //'font-bold',
  //'hover:text-blue-800'
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
        'primary': '#d4b33e',
        'primary-dark': '#c0a32e',
        'secondary': '#c06627',
        'secondary-dark': '#a85520',
        'light-yellow': '#fff8e8',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
      require('@tailwindcss/line-clamp'),
  ]
}