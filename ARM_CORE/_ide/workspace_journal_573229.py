# 2026-06-18T22:25:39.269422181
import vitis

client = vitis.create_client()
client.set_workspace(path="ARM_CORE")

platform = client.get_component(name="arm_platform")
status = platform.build()

comp = client.get_component(name="arm_application")
comp.build()

vitis.dispose()

