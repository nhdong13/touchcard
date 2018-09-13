const environment = require('./environment')
const CompressionPlugin = require('compression-webpack-plugin')
const merge = require('webpack-merge')
const customConfig = require('./custom')

// environment.plugins.append('UglifyJs', new webpack.optimize.UglifyJsPlugin({
//   sourceMap: true
// }))

environment.plugins.append('Compression', new CompressionPlugin({
  asset: '[path].gz[query]',
  algorithm: 'gzip',
  test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
}))

module.exports = merge(environment.toWebpackConfig(), customConfig)
