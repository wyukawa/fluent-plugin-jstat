# fluent-plugin-jstat

[Fluentd](http://fluentd.org) plugin to input jstat command result.

## Installation
install with gem or fluent-gem command as:

`````
### native gem
$ gem install fluent-plugin-jstat

### fluentd gem
$ fluent-gem install fluent-plugin-jstat
`````

## Configuration

```
<source>
  type jstat
  option -gcutil
  emit_interval 60
  tag hiveserver.jstat
  pid_path /var/run/hiveserver.pid
  scale 100
 </source>
```

#### Parameters

* option
  * option for jstat command (for example, -gcutil)
* emit_interval
  * emit interval second (default: 60)
* tag
  * emit tag
* pid_path
  * pid file path. fluent-plugin-jstat executes jstat command with process id written by thie path.
* scale
  * scale jstat command resultz(default: 1)

## Output

```
2014-03-17 13:44:36 +0900 hiveserver.jstat: {"S0":0.0,"S1":0.0,"E":1.25,"O":41.29,"P":63.54,"YGC":253.0,"YGCT":1.519,"FGC":252.0,"FGCT":137.145,"GCT":138.665}
2014-03-17 13:44:41 +0900 hiveserver.jstat: {"S0":0.0,"S1":0.0,"E":1.44,"O":41.29,"P":63.54,"YGC":253.0,"YGCT":1.519,"FGC":252.0,"FGCT":137.145,"GCT":138.665}
2014-03-17 13:44:46 +0900 hiveserver.jstat: {"S0":0.0,"S1":0.0,"E":1.97,"O":41.29,"P":63.54,"YGC":253.0,"YGCT":1.519,"FGC":252.0,"FGCT":137.145,"GCT":138.665}
```

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/wyukawa/fluent-plugin-jstat/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
