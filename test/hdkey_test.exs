defmodule HdkeyTest do
  use ExUnit.Case

  test "generete master hdkey from hex seed" do
    hdkey = Hdkey.from_master_seed("6411fc4e712edf19a06bc5")

    assert hdkey.private_key == "019501a2dcd7b5450388df7e3b426a5422c3570425296f206fecee56f332c079"

    assert hdkey.public_key ==
             "02962f81719ca3de1c431c15af996bb9558b1790d8031cbfe702276fb754d44d33"

    assert hdkey.chain_code == "a386d620fc62c7a6a4ed83a19a0638c54c1486d8d8a60bfeeacac1b7a2e2e911"
    assert hdkey.depth == 0
    assert hdkey.index == 0
  end

  test "to bip32" do
    hdkey = Hdkey.from_master_seed("6411fc4e712edf19a06bc5")

    bip32 = Hdkey.to_json(hdkey)

    assert bip32.xprv ==
             "xprv9s21ZrQH143K3gnXBZCcM9RAqTSzcEn6jK321gwpdN5XYR9i8m7WhRyuWTHgoNJDjVq9TgCQHgs5j875ZCPXVTrpkQwzdtTPUDPitoxJ4t5"

    assert bip32.xpub ==
             "xpub661MyMwAqRbcGArzHajciHMuPVHV1hVx6Xxcp5MSBhcWRDUrgJRmFEJPMjSu7tXdzwvxrFojYP8oYne1X9Y4xWgyfWD3thLxpa3NEnPsMG8"
  end

  test "from bip32 xprv" do
    bip32 =
      "xprv9s21ZrQH143K3gnXBZCcM9RAqTSzcEn6jK321gwpdN5XYR9i8m7WhRyuWTHgoNJDjVq9TgCQHgs5j875ZCPXVTrpkQwzdtTPUDPitoxJ4t5"

    hdkey = Hdkey.from_json(bip32)

    assert hdkey.private_key == "019501a2dcd7b5450388df7e3b426a5422c3570425296f206fecee56f332c079"

    assert hdkey.public_key ==
             "02962f81719ca3de1c431c15af996bb9558b1790d8031cbfe702276fb754d44d33"

    assert hdkey.chain_code == "a386d620fc62c7a6a4ed83a19a0638c54c1486d8d8a60bfeeacac1b7a2e2e911"
    assert hdkey.depth == 0
    assert hdkey.index == 0
  end

  test "from bip32 xpub" do
    bip32 =
      "xpub661MyMwAqRbcGArzHajciHMuPVHV1hVx6Xxcp5MSBhcWRDUrgJRmFEJPMjSu7tXdzwvxrFojYP8oYne1X9Y4xWgyfWD3thLxpa3NEnPsMG8"

    hdkey = Hdkey.from_json(bip32)

    assert hdkey.private_key == nil

    assert hdkey.public_key ==
             "02962f81719ca3de1c431c15af996bb9558b1790d8031cbfe702276fb754d44d33"

    assert hdkey.chain_code == "a386d620fc62c7a6a4ed83a19a0638c54c1486d8d8a60bfeeacac1b7a2e2e911"
    assert hdkey.depth == 0
    assert hdkey.index == 0
  end

  test "derive child hdkey" do
    hdkey = Hdkey.from_master_seed("6411fc4e712edf19a06bc5")
    child_hdkey = Hdkey.derive_child(hdkey, 5)

    assert child_hdkey.private_key ==
             "4ff08af436785a6de1bdea489342a84a0c6d79caef43140375c1ef220c29bc4c"

    assert child_hdkey.public_key ==
             "0207ad96a500055f694c57637897018e771e25af129ad89aacc1b7ea900fb232a1"

    assert child_hdkey.chain_code ==
             "5408be244f01d7ba9900b9d65159e011c128cf067f3281a65e61ca1fb7f5edb2"

    assert child_hdkey.depth == 1
    assert child_hdkey.index == 5
  end

  test "derive by path" do
    hdkey = Hdkey.from_master_seed("6411fc4e712edf19a06bc5")
    descendant_hdkey = Hdkey.derive_descendant_by_path(hdkey, "m/0/3")

    assert descendant_hdkey.private_key ==
             "cb1eaadc10a67bede79b87c444329c0c695d65c0992411d473481693cf13e0c7"

    assert descendant_hdkey.public_key ==
             "03e63af50ed21b5eeb3a073d8653209fdc841274448ad953f4a67de9d0c264a0d3"

    assert descendant_hdkey.chain_code ==
             "8139ac2c9c2d6414dc3679fe26a176ea2cbaa5cb8c7997021c954e35668bd9c3"

    assert descendant_hdkey.depth == 2
    assert descendant_hdkey.index == 3
  end

  test "hardered derive by path" do
    hdkey = Hdkey.from_master_seed("6411fc4e712edf19a06bc5")
    descendant_hdkey = Hdkey.derive_descendant_by_path(hdkey, "m/0'/3")

    assert descendant_hdkey.private_key ==
             "9d87b03846ee0dd07f6ec026844807ee2b7ca6a4e4c778022cbaa855da8cf429"

    assert descendant_hdkey.public_key ==
             "0256a8bca0b4fdfc860623fb971b87101124bd51d17143549efbebc5cfd16c5432"

    assert descendant_hdkey.chain_code ==
             "69d9af470f341cdbf12a566de11b5bc7842c5f61a5a855bcaa839a5da80be09d"

    assert descendant_hdkey.depth == 2
    assert descendant_hdkey.index == 3
  end

  test "hardered derive by path 2" do
    hdkey = Hdkey.from_master_seed("6411fc4e712edf19a06bc5")
    descendant_hdkey = Hdkey.derive_descendant_by_path(hdkey, "m/0'/3'")

    assert descendant_hdkey.private_key ==
             "dd5fb7ef0e6edf6c6021ea2f6c17ef0f136ab6d0313262e892e8e5e4e94fe1a6"

    assert descendant_hdkey.public_key ==
             "022e6ae29b35231552665301812a9effb94b97f911ce0244d63b168e70112592cf"

    assert descendant_hdkey.chain_code ==
             "3c54dc2ae89d7dd91b543008abbebf7bcd2a0e3a669bfc41a8bb0467dd2b97bb"

    assert descendant_hdkey.depth == 2
    assert descendant_hdkey.index == 2_147_483_651
  end

  test "hardened derive without private key" do
    bip32 =
      "xpub661MyMwAqRbcGArzHajciHMuPVHV1hVx6Xxcp5MSBhcWRDUrgJRmFEJPMjSu7tXdzwvxrFojYP8oYne1X9Y4xWgyfWD3thLxpa3NEnPsMG8"

    hdkey = Hdkey.from_json(bip32)

    assert hdkey.private_key == nil

    try do
      Hdkey.derive_descendant_by_path(hdkey, "m/0'")
    rescue
      e in RuntimeError -> assert e.message == "private key missing!"
    end
  end

  test "public key only derive" do
    hdkey = Hdkey.from_master_seed("6411fc4e712edf19a06bc5")
    descendant_hdkey = Hdkey.derive_descendant_by_path(hdkey, "M/0'/3'")

    assert descendant_hdkey.private_key == nil

    assert descendant_hdkey.public_key ==
             "022e6ae29b35231552665301812a9effb94b97f911ce0244d63b168e70112592cf"

    assert descendant_hdkey.chain_code ==
             "3c54dc2ae89d7dd91b543008abbebf7bcd2a0e3a669bfc41a8bb0467dd2b97bb"

    assert descendant_hdkey.depth == 2
    assert descendant_hdkey.index == 2_147_483_651
  end

  # __end_of_module__
end
