# 2026-06-16T01:25:35.263878256
import vitis

client = vitis.create_client()
client.set_workspace(path="SoC-LED-Clock")

# 2026-06-16T01:25:35.263907799
import vitis

client = vitis.create_client()
client.set_workspace(path="SoC-LED-Clock")

platform = client.create_platform_component(name = "arm_core_platform",hw_design = "$COMPONENT_LOCATION/../arm_core_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

status = client.add_platform_repos(platform=["/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/SoC-LED-Clock/arm_core_platform"])

comp = client.create_app_component(name="arm_core_app_component",platform = "$COMPONENT_LOCATION/../arm_core_platform/export/arm_core_platform/arm_core_platform.xpfm",domain = "standalone_ps7_cortexa9_0")

platform = client.get_component(name="arm_core_platform")
status = platform.build()

status = platform.build()

comp = client.get_component(name="arm_core_app_component")
comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

