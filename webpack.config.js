const path = require('path');

module.exports = {
  entry: './app/javascript/application.js',
  output: {
    filename: 'application.js',
    path: path.resolve(__dirname, 'app/assets/builds'),
  },
  // outras configs...
};