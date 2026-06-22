# 2026-06-22T12:29:08.075785916
import vitis

client = vitis.create_client()
client.set_workspace(path="ARM_CORE")

vitis.dispose()

