module.exports = {
  chainWebpack: config => {
    config
      .plugin('html')
      .tap(args => {
        args[0].title = "Intelligent Platform";
        return args;
      })
  },
  devServer: {
    port: 3000
  }
}