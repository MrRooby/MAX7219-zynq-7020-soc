# 2026-06-18T18:59:21.349609369
import vitis

client = vitis.create_client()
client.set_workspace(path="ARM_CORE")

vitis.dispose()

