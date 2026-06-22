# 2026-06-22T12:42:12.314752478
import vitis

client = vitis.create_client()
client.set_workspace(path="ARM_CORE")

platform = client.get_component(name="arm_platform")
status = platform.build()

comp = client.get_component(name="arm_application")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

