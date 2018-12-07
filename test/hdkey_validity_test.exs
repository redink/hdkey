defmodule HdkeyValidityTest do
  use ExUnit.Case

  test_data =
    "./priv/validity_test_data.json"
    |> File.read!()
    |> Jason.decode!(keys: :atoms)

  test_data
  |> Enum.map(fn %{master_seed: master_seed} = data ->
    test "hdkey validity test, for master seed: #{master_seed}" do
      %{master_seed: master_seed, master_key_json: master_key_json, descendants: descendants} =
        unquote(Macro.escape(data))

      master_key = Hdkey.from_master_seed(master_seed)
      json_from_master_key = Hdkey.to_json(master_key)
      assert json_from_master_key == master_key_json
      assert_descendants(master_key, descendants)
    end
  end)

  defp assert_descendants(master_key, descendants) do
    descendants
    |> Enum.map(fn %{path: path, xprv: xprv, xpub: xpub} ->
      child_key = Hdkey.derive_descendant_by_path(master_key, path)
      %{xprv: child_xprv, xpub: child_xpub} = Hdkey.to_json(child_key)
      assert child_xprv == xprv
      assert child_xpub == xpub
    end)
  end

  # __end_of_module__
end
