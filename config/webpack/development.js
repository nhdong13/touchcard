const environment = require('./environment')
const CompressionPlugin = require('compression-webpack-plugin')

// environment.plugins.set('UglifyJs', new webpack.optimize.UglifyJsPlugin({
//   sourceMap: true
// }))

environment.plugins.set('Compression', new CompressionPlugin({
  asset: '[path].gz[query]',
  algorithm: 'gzip',
  test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
}))

module.exports = environment.toWebpackConfig()
