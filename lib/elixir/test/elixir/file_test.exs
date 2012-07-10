Code.require_file "../test_helper", __FILE__

defmodule FileTest do
  use ExUnit.Case

  test :expand_path_with_binary do
    assert File.expand_path("/foo/bar") == "/foo/bar"
    assert File.expand_path("/foo/bar/") == "/foo/bar"
    assert File.expand_path("/foo/bar/.") == "/foo/bar"
    assert File.expand_path("/foo/bar/../bar") == "/foo/bar"

    assert File.expand_path("bar", "/foo") == "/foo/bar"
    assert File.expand_path("bar/", "/foo") == "/foo/bar"
    assert File.expand_path("bar/.", "/foo") == "/foo/bar"
    assert File.expand_path("bar/../bar", "/foo") == "/foo/bar"
    assert File.expand_path("../bar/../bar", "/foo/../foo/../foo") == "/bar"

    full = File.expand_path("foo/bar")
    assert File.expand_path("bar/../bar", "foo") == full
  end

  test :expand_path_with_list do
    assert File.expand_path('/foo/bar') == '/foo/bar'
    assert File.expand_path('/foo/bar/') == '/foo/bar'
    assert File.expand_path('/foo/bar/.') == '/foo/bar'
    assert File.expand_path('/foo/bar/../bar') == '/foo/bar'
  end

  test :rootname_with_binary do
    assert File.rootname("~/foo/bar.ex", ".ex") == "~/foo/bar"
    assert File.rootname("~/foo/bar.exs", ".ex") == "~/foo/bar.exs"
    assert File.rootname("~/foo/bar.old.ex", ".ex") == "~/foo/bar.old"
  end

  test :rootname_with_list do
    assert File.rootname('~/foo/bar.ex', '.ex') == '~/foo/bar'
    assert File.rootname('~/foo/bar.exs', '.ex') == '~/foo/bar.exs'
    assert File.rootname('~/foo/bar.old.ex', '.ex') == '~/foo/bar.old'
  end

  test :extname_with_binary do
    assert File.extname("foo.erl") == ".erl"
    assert File.extname("~/foo/bar") == ""
  end

  test :extname_with_list do
    assert File.extname('foo.erl') == '.erl'
    assert File.extname('~/foo/bar') == ''
  end

  test :dirname_with_binary do
    assert File.dirname("/foo/bar.ex") == "/foo"
    assert File.dirname("~/foo/bar.ex") == "~/foo"
    assert File.dirname("/foo/bar/baz/") == "/foo/bar/baz"
  end

  test :dirname_with_list do
    assert File.dirname('/foo/bar.ex') == '/foo'
    assert File.dirname('~/foo/bar.ex') == '~/foo'
    assert File.dirname('/foo/bar/baz/') == '/foo/bar/baz'
  end

  test :regular do
    assert File.regular?(__FILE__)
    assert File.regular?(binary_to_list(__FILE__))
    refute File.regular?("#{__FILE__}.unknown")
  end

  test :exists do
    assert File.exists?(__FILE__)
    assert File.exists?(File.expand_path("../fixtures/foo.txt", __FILE__))
    assert File.exists?(File.expand_path("../fixtures/", __FILE__))

    refute File.exists?("fixtures/missing.txt")
    refute File.exists?("_missing.txt")
  end

  test :basename_with_binary do
    assert File.basename("foo") == "foo"
    assert File.basename("/foo/bar") == "bar"
    assert File.basename("/") == ""

    assert File.basename("~/foo/bar.ex", ".ex") == "bar"
    assert File.basename("~/foo/bar.exs", ".ex") == "bar.exs"
    assert File.basename("~/for/bar.old.ex", ".ex") == "bar.old"
  end

  test :basename_with_list do
    assert File.basename('foo') == 'foo'
    assert File.basename('/foo/bar') == 'bar'
    assert File.basename('/') == ''

    assert File.basename('~/foo/bar.ex', '.ex') == 'bar'
    assert File.basename('~/foo/bar.exs', '.ex') == 'bar.exs'
    assert File.basename('~/for/bar.old.ex', '.ex') == 'bar.old'
  end

  test :join_with_binary do
    assert File.join([""]) == ""
    assert File.join(["foo"]) == "foo"
    assert File.join(["/", "foo", "bar"]) == "/foo/bar"
    assert File.join(["~", "foo", "bar"]) == "~/foo/bar"
  end

  test :join_with_list do
    assert File.join(['']) == ''
    assert File.join(['foo']) == 'foo'
    assert File.join(['/', 'foo', 'bar']) == '/foo/bar'
    assert File.join(['~', 'foo', 'bar']) == '~/foo/bar'
  end

  test :join_two_with_binary do
    assert File.join("/foo", "bar") == "/foo/bar"
    assert File.join("~", "foo") == "~/foo"
  end

  test :join_two_with_list do
    assert File.join('/foo', 'bar') == '/foo/bar'
    assert File.join('~', 'foo') == '~/foo'
  end

  test :split_with_binary do
    assert File.split("") == ["/"]
    assert File.split("foo") == ["foo"]
    assert File.split("/foo/bar") == ["/", "foo", "bar"]
  end

  test :split_with_list do
    assert File.split('') == ''
    assert File.split('foo') == ['foo']
    assert File.split('/foo/bar') == ['/', 'foo', 'bar']
  end

  test :read_with_binary do
    assert { :ok, "FOO\n" } = File.read(File.expand_path("../fixtures/foo.txt", __FILE__))
    assert { :error, :enoent } = File.read(File.expand_path("../fixtures/missing.txt", __FILE__))
  end

  test :read_with_list do
    assert { :ok, "FOO\n" } = File.read(File.expand_path('../fixtures/foo.txt', __FILE__))
    assert { :error, :enoent } = File.read(File.expand_path('../fixtures/missing.txt', __FILE__))
  end

  test :read_with_utf8 do
    assert { :ok, "Русский\n日\n" } = File.read(File.expand_path('../fixtures/utf8.txt', __FILE__))
  end

  test :read! do
    assert File.read!(File.expand_path("../fixtures/foo.txt", __FILE__)) == "FOO\n"
    expected_message = "could not read file fixtures/missing.txt: no such file or directory"

    assert_raise File.Error, expected_message, fn ->
      File.read!("fixtures/missing.txt")
    end
  end

  test :stat do
    {:ok, info} = File.stat(__FILE__)
    assert info.mtime
  end

  test :stat! do
    assert File.stat!(__FILE__).mtime
  end

  test :stat_with_invalid_file do
    assert { :error, _ } = File.stat("./invalid_file")
  end

  test :stat_with_invalid_file! do
    assert_raise File.Error, fn ->
      File.stat!("./invalid_file")
    end
  end

  test :mkdir_with_binary do
    try do
      refute File.exists?("tmp_test")
      File.mkdir("tmp_test")
      assert File.exists?("tmp_test")
    after
      :os.cmd('rm -rf tmp_test')
    end
  end

  test :mkdir_with_list do
    try do
      refute File.exists?('tmp_test')
      assert File.mkdir('tmp_test') == :ok
      assert File.exists?('tmp_test')
    after
      :os.cmd('rm -rf tmp_test')
    end
  end

  test :mkdir_with_invalid_path do
    assert File.exists?('test/elixir/file_test.exs')
    assert File.mkdir('test/elixir/file_test.exs/test') == { :error, :enotdir }
    refute File.exists?('test/elixir/file_test.exs/test')
  end

  test :mkdir_p_with_one_directory do
    try do
      refute File.exists?("tmp_test")
      assert File.mkdir_p("tmp_test") == :ok
      assert File.exists?("tmp_test")
    after
      :os.cmd('rm -rf tmp_test')
    end
  end

  test :mkdir_p_with_nested_directory_and_binary do
    try do
      refute File.exists?("tmp_test")
      assert File.mkdir_p("tmp_test/test") == :ok
      assert File.exists?("tmp_test")
      assert File.exists?("tmp_test/test")
    after
      :os.cmd('rm -rf tmp_test')
    end
  end

  test :mkdir_p_with_nested_directory_and_list do
    try do
      refute File.exists?('tmp_test')
      assert File.mkdir_p('tmp_test/test') == :ok
      assert File.exists?('tmp_test')
      assert File.exists?('tmp_test/test')
    after
      :os.cmd('rm -rf tmp_test')
    end
  end

  test :mkdir_p_with_nested_directory_and_existent_parent do
    try do
      refute File.exists?("tmp_test")
      File.mkdir("tmp_test")
      assert File.exists?("tmp_test")
      assert File.mkdir_p("tmp_test/test") == :ok
      assert File.exists?("tmp_test/test")
    after
      :os.cmd('rm -rf tmp_test')
    end
  end

  test :mkdir_p_with_invalid_path do
    assert File.exists?('test/elixir/file_test.exs')
    assert File.mkdir('test/elixir/file_test.exs/test/foo') == { :error, :enotdir }
    refute File.exists?('test/elixir/file_test.exs/test/foo')
  end

  test :write_normal_content do
    try do
      refute File.exists?('test/elixir/tmp_test.txt')
      assert File.write('test/elixir/tmp_test.txt', 'test text') == :ok
      assert { :ok, "test text" } == File.read('test/elixir/tmp_test.txt')
    after
      File.rm('test/elixir/tmp_test.txt')
    end
  end

  test :write_utf8 do
    try do
      refute File.exists?('test/elixir/tmp_test.txt')
      assert File.write('test/elixir/tmp_test.txt', "Русский\n日\n") == :ok
      assert { :ok, "Русский\n日\n" } == File.read('test/elixir/tmp_test.txt')
    after
      File.rm('test/elixir/tmp_test.txt')
    end
  end

  test :write_with_options do
    try do
      refute File.exists?('test/elixir/tmp_test.txt')
      assert File.write('test/elixir/tmp_test.txt', "Русский\n日\n") == :ok
      assert File.write('test/elixir/tmp_test.txt', "test text", [:append]) == :ok
      assert { :ok, "Русский\n日\ntest text" } == File.read('test/elixir/tmp_test.txt')
    after
      File.rm('test/elixir/tmp_test.txt')
    end
  end

  test :rm_file do
    File.write('test/elixir/tmp_test.txt', "test")
    assert File.exists?('test/elixir/tmp_test.txt')
    assert File.rm('test/elixir/tmp_test.txt') == :ok
    refute File.exists?('test/elixir/tmp_test.txt')
  end

  test :rm_file_with_dir do
    assert File.rm('test/') == {:error, :eperm}
  end

  test :rm_nonexistent_file do
    assert File.rm('missing.txt') == {:error, :enoent}
  end

  test :open_file_without_modes do
    { :ok, file } = File.open(File.expand_path("../fixtures/foo.txt", __FILE__))
    assert IO.gets(file, "") == "FOO\n"
    assert File.close(file) == :ok
  end

  test :open_file_with_charlist do
    { :ok, file } = File.open(File.expand_path("../fixtures/foo.txt", __FILE__), [:charlist])
    assert IO.gets(file, "") == 'FOO\n'
    assert File.close(file) == :ok
  end

  test :open_utf8_by_default do
    { :ok, file } = File.open(File.expand_path("../fixtures/utf8.txt", __FILE__))
    assert IO.gets(file, "") == "Русский\n"
    assert File.close(file) == :ok
  end

  test :open_readonly_by_default do
    { :ok, file } = File.open(File.expand_path("../fixtures/utf8.txt", __FILE__))
    assert_raise ArgumentError, fn -> IO.write(file, "foo") end
    assert File.close(file) == :ok
  end

  test :open_with_write_permission do
    try do
      { :ok, file } = File.open("test/elixir/tmp_test.txt", [:write])
      assert IO.write(file, "foo") == :ok
      assert File.close(file) == :ok
      assert File.read('test/elixir/tmp_test.txt') == { :ok, "foo" }
    after
      File.rm('test/elixir/tmp_test.txt')
    end
  end

  test :open_utf8_and_charlist do
    { :ok, file } = File.open(File.expand_path("../fixtures/utf8.txt", __FILE__), [:charlist])
    assert IO.gets(file, "") == [1056,1091,1089,1089,1082,1080,1081,10]
    assert File.close(file) == :ok
  end

  test :open_respects_encoding do
    { :ok, file } = File.open(File.expand_path("../fixtures/utf8.txt", __FILE__), [{:encoding, :latin1}])
    assert IO.gets(file, "") == <<195,144,194,160,195,145,194,131,195,145,194,129,195,145,194,129,195,144,194,186,195,144,194,184,195,144,194,185,10>>
    assert File.close(file) == :ok
  end

  test :open_a_missing_file do
    assert File.open('missing.txt') == {:error, :enoent}
  end
end