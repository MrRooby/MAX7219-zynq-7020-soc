# 2026-06-18T22:19:41.813379531
import vitis

client = vitis.create_client()
client.set_workspace(path="ARM_CORE")

vitis.dispose()

