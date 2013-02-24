exports.info =
  name: 'sysinfo'
  description: 'Display some system information'
  menus: [
    title: 'SysInfo'
    controller: 'SysInfoCtrl'
  ]
  rpcs: ['sysInfo']

child_process = require 'child_process'

exports.sysInfo = (cb) ->

  child_process.exec 'uptime', (err, up, serr) ->
    throw err  if err
    child_process.exec 'df -H', (err, df, serr) ->
      throw err  if err
      child_process.exec 'ps xl', (err, ps, serr) ->
        throw err  if err
        cb null,
          up: up
          df: df
          ps: ps
