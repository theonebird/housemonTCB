# temporary static node map and other data for now
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

    "RF12:868:5:2": title: 'boekenkast JC'
    "RF12:868:5:3": title: 'buro JC'
    "RF12:868:5:4": title: 'washok'
    "RF12:868:5:5": title: 'woonkamer'
    "RF12:868:5:6": title: 'hal vloer'
    "RF12:868:5:9": title: 'meterkast'
    "RF12:868:5:10": title: 'hal voor'
    "RF12:868:5:11": title: 'logeerkamer'
    "RF12:868:5:12": title: 'boekenkast L'
    "RF12:868:5:13": title: 'raam halfhoog'
    "RF12:868:5:14": title: 'zolderkamer'
    "RF12:868:5:15": title: 'washok'
    "RF12:868:5:18": title: 'meterkast'
    "RF12:868:5:19": title: 'kantoor'
    "RF12:868:5:20": title: 'labtafel'
    "RF12:868:5:23": title: 'gang boven'
    "RF12:868:5:24": title: 'zolderkamer'

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
        scale: 1
        min: -50
        max: 50

    #ookRelay2:

    smaRelay:
      acw:
        title: 'PV power AC'
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
        scale: 3
        min: 0
      yield:
        title: 'PV daily yield'
        unit: 'kWh'
        scale: 3
        min: 0
        max: 50

    #otRelay:

    p1scanner:
      use1:
        title: 'Elec usage - low'
        unit: 'kWh'
        scale: 3
        min: 0
      use2:
        title: 'Elec usage - high'
        unit: 'kWh'
        scale: 3
        min: 0
      gen1:
        title: 'Elec return - low'
        unit: 'kWh'
        scale: 3
        min: 0
      gen2:
        title: 'Elec return - high'
        unit: 'kWh'
        scale: 3
        min: 0
      mode:
        title: 'Mode'
      usew:
        title: 'Elec usage now'
        unit: 'W'
        scale: -1
        min: 0
        max: 15000
      genw:
        title: 'Elec return now'
        unit: 'W'
        scale: -1
        min: 0
        max: 10000
      gas:
        title: 'Gas total'
        unit: 'm3'
        scale: 3
        min: 0

    homePower:
      c1:
        title: 'Counter stove'
        unit: 'kWh'
        factor: 0.5
        scale: 3
        min: 0
        max: 33
      c2:
        title: 'Counter solar'
        unit: 'kWh'
        factor: 0.5
        scale: 3
        min: 0
        max: 33
      c3:
        title: 'Counter house'
        unit: 'kWh'
        factor: 0.5
        scale: 3
        min: 0
        max: 33
      p1:
        title: 'Usage stove'
        unit: 'W'
        scale: 1
        min: 0
        max: 10000
      p2:
        title: 'Production solar'
        unit: 'W'
        scale: 1
        min: 0
        max: 10000
      p3:
        title: 'Usage house'
        unit: 'W'
        scale: 1
        min: 0
        max: 10000

    radioBlip:
      age:
        title: 'Estimated age'
        unit: 'days'
        min: 0
      ping:
        title: 'Ping count'
        min: 0

    slowLogger:
      a0:
        title: 'Input 0'
        unit: 'V'
        factor: 3.3 / 32
        scale: 3
        min: 0
        max: 4
      a1:
        title: 'Input 1'
        unit: 'V'
        factor: 3.3 / 32
        scale: 3
        min: 0
        max: 4
      a2:
        title: 'Input 2'
        unit: 'V'
        factor: 3.3 / 32
        scale: 3
        min: 0
        max: 4
      a3:
        title: 'Input 3'
        unit: 'V'
        factor: 3.3 / 32
        scale: 3
        min: 0
        max: 4
