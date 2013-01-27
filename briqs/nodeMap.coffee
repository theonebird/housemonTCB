# temporary static node map for now
# module is not treated as a briq, because it does not export an 'info' entry

module.exports =

  11: 'roomNode'
  12: 'ookRelay2'
  13: 'smaRelay'
  14: 'otRelay'
  15: 'p1scanner'
  16: 'homePower'
  17: 'radioBlip'
  18: 'slowLogger'

  # this is still used for parsing logs which do not include announcer packets
  # TODO: needs to be time-dependent, since the config can change over time
  868:
    5:
      2: 'roomNode'
      3: 'radioBlip'
      4: 'roomNode'
      5: 'roomNode'
      6: 'roomNode'
      9: 'homePower'
      10: 'roomNode'
      11: 'roomNode'
      12: 'roomNode'
      13: 'roomNode'
      14: 'otRelay'
      15: 'smaRelay'
      18: 'p1scanner'
      19: 'ookRelay2'
      20: 'slowLogger'
      23: 'roomNode'
      24: 'roomNode'

  # devices are mapped to RF12 configs, since that is not present in log files
  # TODO: same time-dependent comment as above, this mapping is not fixed
  'usb-A40117UK':
    recvid: 1
    group: 5
    band: 868

  locations:

    "RF12:868:5:2":
      title: 'boekenkast JC'
    "RF12:868:5:3":
      title: 'buro JC'
    "RF12:868:5:4":
      title: 'wasmachine'
    "RF12:868:5:5":
      title: 'schoorsteen'
    "RF12:868:5:6":
      title: 'hal vloer'
    "RF12:868:5:9":
      title: 'meterkast'
    "RF12:868:5:10":
      title: 'hal voor'
    "RF12:868:5:11":
      title: 'logeerkamer'
    "RF12:868:5:12":
      title: 'boekenkast L'
    "RF12:868:5:13":
      title: 'raam halfhoog'
    "RF12:868:5:14":
      title: 'zolderkamer'
    "RF12:868:5:15":
      title: 'wasmachine'
    "RF12:868:5:18":
      title: 'meterkast'
    "RF12:868:5:19":
      title: 'kantoor'
    "RF12:868:5:20":
      title: 'labtafel'
    "RF12:868:5:23":
      title: 'gang boven'
    "RF12:868:5:24":
      title: 'zolderkamer'

  drivers:

    roomNode:
      humi:
        title: 'Relative humidity'
        unit: '%'
        min: 0
        max: 100
      light:
        title: 'Light intensity'
        min: 0
        max: 100
      moved:
        title: 'Motion'
        min: 0
        max: 1
      temp:
        title: 'Temperature'
        unit: '°C'
        min: -50
        max: 50
        scale: 1

    #ookRelay2:

    smaRelay:
      acw:
        title: 'AC power'
        unit: 'W'
        min: 0
        max: 6000
      dcv1:
        title: 'PV level east'
        unit: 'V'
        min: 0
        max: 250
      dcv2:
        title: 'PV level west'
        unit: 'V'
        min: 0
        max: 250
      dcw1:
        title: 'PV power east'
        unit: 'W'
        min: 0
        max: 4000
      dcw2:
        title: 'PV power west'
        unit: 'W'
        min: 0
        max: 4000
      total:
        title: 'PV total'
        unit: 'MWh'
        min: 0
        scale: 3
      yield:
        title: 'PV daily yield'
        unit: 'kWh'
        min: 0
        max: 50
        scale: 3

    #otRelay:

    #p1scanner:

    homePower:
      c1:
        title: 'Stove pulse counter'
        unit: 'x'
        min: 0
        max: 66000
      c2:
        title: 'Solar pulse counter'
        unit: 'x'
        min: 0
        max: 66000
      c3:
        title: 'House pulse counter'
        unit: 'x'
        min: 0
        max: 66000
      p1:
        title: 'Stove power'
        unit: 'W'
        min: 0
        max: 10000
      p2:
        title: 'Solar power'
        unit: 'W'
        min: 0
        max: 10000
      p3:
        title: 'House power'
        unit: 'W'
        min: 0
        max: 10000

    radioBlip:
      age:
        title: 'Estimated age'
        unit: 'days'
        min: 0
      ping:
        title: 'Ping count'
        unit: 'x'
        min: 0
    slowLogger:
      a1:
        title: 'Input 1'
        min: 0
        max: 1023
        factor: 0.03125
      a2:
        title: 'Input 2'
        min: 0
        max: 1023
        factor: 0.03125
      a3:
        title: 'Input 3'
        min: 0
        max: 1023
        factor: 0.03125
      a4:
        title: 'Input 4'
        min: 0
        max: 1023
        factor: 0.03125
