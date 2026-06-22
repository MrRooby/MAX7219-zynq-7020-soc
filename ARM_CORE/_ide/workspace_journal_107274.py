# 2026-06-22T12:19:38.787772034
import vitis

client = vitis.create_client()
client.set_workspace(path="ARM_CORE")

vitis.dispose()

