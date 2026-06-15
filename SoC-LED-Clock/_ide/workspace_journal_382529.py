# 2026-06-15T23:36:18.825539954
import vitis

client = vitis.create_client()
client.set_workspace(path="SoC-LED-Clock")

platform = client.create_platform_component(name = "arm_core_platform",hw_design = "$COMPONENT_LOCATION/../arm_core_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

vitis.dispose()

