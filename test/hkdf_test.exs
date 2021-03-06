defmodule HKDFTest do
  use ExUnit.Case
  doctest HKDF
  import Utils

  describe "extract keys of correct size" do
    test_all_hash_funs "with default salt" do
      expected =
        :crypto.hash(fun, "")
        |> byte_size()
      key = HKDF.extract(fun, "secret")

      assert byte_size(key) === expected
    end

    test_all_hash_funs "with provided salt" do
      expected =
        :crypto.hash(fun, "")
        |> byte_size()
      salt = :crypto.strong_rand_bytes(expected)
      key = HKDF.extract(fun, "secret", salt)

      assert byte_size(key) === expected
    end
  end

  describe "expand keys to correct size" do
    test_all_hash_funs "with default info" do
      len = 16
      key = HKDF.extract(fun, "secret")
      output = HKDF.expand(fun, key, len)

      assert byte_size(output) === len
    end

    test_all_hash_funs "with provided info" do
      len = 16
      key = HKDF.extract(fun, "secret")
      output = HKDF.expand(fun, key, len, "message")

      assert byte_size(output) === len
    end
  end

  describe "rfc 5869 test cases" do
    test "basic sha-256" do
      hash = :sha256
      ikm = <<0x0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b :: unit(8)-size(22)>>
      salt = <<0x000102030405060708090a0b0c :: unit(8)-size(13)>>
      info = <<0xf0f1f2f3f4f5f6f7f8f9 :: unit(8)-size(10)>>
      l = 42
      prk = <<0x077709362c2e32df0ddc3f0dc47bba6390b6c73bb50f9c3122ec844ad7c2b3e5 :: unit(8)-size(32)>>
      okm = <<0x3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865 :: unit(8)-size(l)>>
      test_case(hash, ikm, salt, info, l, prk, okm)
    end

    test "sha-256 with longer input/ouputs" do
      hash = :sha256
      ikm = <<0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f :: unit(8)-size(80)>>
      salt = <<0x606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeaf :: unit(8)-size(80)>>
      info = <<0xb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff :: unit(8)-size(80)>>
      l = 82
      prk = <<0x06a6b88c5853361a06104c9ceb35b45cef760014904671014a193f40c15fc244 :: unit(8)-size(32)>>
      okm = <<0xb11e398dc80327a1c8e7f78c596a49344f012eda2d4efad8a050cc4c19afa97c59045a99cac7827271cb41c65e590e09da3275600c2f09b8367793a9aca3db71cc30c58179ec3e87c14c01d5c1f3434f1d87 :: unit(8)-size(l)>>
      test_case(hash, ikm, salt, info, l, prk, okm)
    end

    test "sha-256 with zero length salt/info" do
      hash = :sha256
      ikm = <<0x0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b :: unit(8)-size(22)>>
      salt = ""
      info = ""
      l = 42
      prk = <<0x19ef24a32c717b167f33a91d6f648bdf96596776afdb6377ac434c1c293ccb04 :: unit(8)-size(32)>>
      okm = <<0x8da4e775a563c18f715f802a063c5a31b8a11f5c5ee1879ec3454e5f3c738d2d9d201395faa4b61a96c8 :: unit(8)-size(l)>>
      test_case(hash, ikm, salt, info, l, prk, okm)
    end

    test "basic sha-1" do
      hash = :sha
      ikm = <<0x0b0b0b0b0b0b0b0b0b0b0b :: unit(8)-size(11)>>
      salt = <<0x000102030405060708090a0b0c :: unit(8)-size(13)>>
      info = <<0xf0f1f2f3f4f5f6f7f8f9 :: unit(8)-size(10)>>
      l = 42
      prk = <<0x9b6c18c432a7bf8f0e71c8eb88f4b30baa2ba243 :: unit(8)-size(20)>>
      okm = <<0x085a01ea1b10f36933068b56efa5ad81a4f14b822f5b091568a9cdd4f155fda2c22e422478d305f3f896 :: unit(8)-size(l)>>
      test_case(hash, ikm, salt, info, l, prk, okm)
    end

    test "sha-1 with longer input/ouputs" do
      hash = :sha
      ikm = <<0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f :: unit(8)-size(80)>>
      salt = <<0x606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeaf :: unit(8)-size(80)>>
      info = <<0xb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff :: unit(8)-size(80)>>
      l = 82
      prk = <<0x8adae09a2a307059478d309b26c4115a224cfaf6 :: unit(8)-size(20)>>
      okm = <<0x0bd770a74d1160f7c9f12cd5912a06ebff6adcae899d92191fe4305673ba2ffe8fa3f1a4e5ad79f3f334b3b202b2173c486ea37ce3d397ed034c7f9dfeb15c5e927336d0441f4c4300e2cff0d0900b52d3b4 :: unit(8)-size(l)>>
      test_case(hash, ikm, salt, info, l, prk, okm)
    end

    test "sha-1 with zero length salt/info" do
      hash = :sha
      ikm = <<0x0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b :: unit(8)-size(22)>>
      salt = ""
      info = ""
      l = 42
      prk = <<0xda8c8a73c7fa77288ec6f5e7c297786aa0d32d01 :: unit(8)-size(20)>>
      okm = <<0x0ac1af7002b3d761d1e55298da9d0506b9ae52057220a306e07b6b87e8df21d0ea00033de03984d34918 :: unit(8)-size(l)>>
      test_case(hash, ikm, salt, info, l, prk, okm)
    end

    defp test_case(hash, ikm, salt, info, l, prk, okm) do
      key = HKDF.extract(hash, ikm, salt)
      assert key === prk

      output = HKDF.expand(hash, prk, l, info)
      assert output === okm
    end
  end
end
