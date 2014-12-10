require_relative '../helper'

class JstatInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG_PID_PATH = %[
    type jstat
    option -gcutil
    emit_interval 1
    tag t1
    pid_path #{File.expand_path('../data/test.pid', __FILE__)}
    scale 100
  ]

  CONFIG_PROCESS_NAME = %[
    type jstat
    option -gcutil
    emit_interval 1
    tag t2
    process_name ruby
    scale 100
  ]

  def create_driver(conf)
    Fluent::Test::InputTestDriver.new(Fluent::JstatInput).configure(conf)
  end

  def test_configure_pid_path
    d = create_driver(CONFIG_PID_PATH)
    assert_equal(1, d.instance.emit_interval)
    assert_equal("-gcutil", d.instance.option)
    assert_equal("t1", d.instance.tag)
    assert_equal(File.expand_path('../data/test.pid', __FILE__), d.instance.pid_path)
    assert_nil(d.instance.process_name)
    assert_equal(100, d.instance.scale)
  end

  def test_configure_process_name
    d = create_driver(CONFIG_PROCESS_NAME)
    assert_equal(1, d.instance.emit_interval)
    assert_equal("-gcutil", d.instance.option)
    assert_equal("t2", d.instance.tag)
    assert_nil(d.instance.pid_path)
    assert_equal("ruby", d.instance.process_name)
    assert_equal(100, d.instance.scale)
  end

  def test_configure_error
    assert_raise(Fluent::ConfigError) {
      create_driver(%[
        type jstat
        option -gcutil
        emit_interval 1
        tag t3
        scale 100
      ])
    }
  end

  def test_emit_pid_path
    mock.instance_of(Fluent::JstatInput).exec_command("jstat -gcutil 777").at_least(1) {
      [
        "  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT",
        "0.00  61.92  93.54  63.60  60.85    105    1.736     2    0.022    1.758"
      ]
    }

    d = create_driver(CONFIG_PID_PATH)
    d.run { sleep(2) }

    emits = d.emits
    assert(emits.length > 0)
    assert_equal('t1', emits[0][0])
    assert_equal(6192, emits[0][2]['S1'])
  end

  def test_emit_process_name
    mock.instance_of(Fluent::JstatInput).exec_command("pgrep -f \"ruby\"").at_least(1) { ["777"] }
    mock.instance_of(Fluent::JstatInput).exec_command("jstat -gcutil 777").at_least(1) {
      [
        "  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT",
        "0.00  61.92  93.54  63.60  60.85    105    1.736     2    0.022    1.758"
      ]
    }

    d = create_driver(CONFIG_PROCESS_NAME)
    d.run { sleep(2) }

    emits = d.emits
    assert(emits.length > 0)
    assert_equal('t2', emits[0][0])
    assert_equal(6192, emits[0][2]['S1'])
  end
end
