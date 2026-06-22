# 2026-06-22T11:26:45.070134678
import vitis

client = vitis.create_client()
client.set_workspace(path="ARM_CORE")

platform = client.get_component(name="arm_platform")
status = platform.build()

comp = client.get_component(name="arm_application")
comp.build()

status = platform.build()

status = comp.clean()

comp.build()

status = comp.clean()

status = platform.build()

comp.build()

vitis.dispose()

