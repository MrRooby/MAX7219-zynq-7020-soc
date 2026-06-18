# 2026-06-18T15:26:09.230757875
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

status = platform.update_hw(hw_design = "$COMPONENT_LOCATION/../main_wrapper.xsa")

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

