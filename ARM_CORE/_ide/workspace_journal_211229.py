# 2026-06-18T13:57:36.123426986
import vitis

client = vitis.create_client()
client.set_workspace(path="ARM_CORE")

platform = client.create_platform_component(name = "arm_platform",hw_design = "$COMPONENT_LOCATION/../main_wrapper.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

status = client.add_platform_repos(platform=["/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/ARM_CORE/arm_platform"])

comp = client.create_app_component(name="arm_application",platform = "$COMPONENT_LOCATION/../arm_platform/export/arm_platform/arm_platform.xpfm",domain = "standalone_ps7_cortexa9_0")

comp = client.get_component(name="arm_application")
status = comp.import_files(from_loc="", files=["/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/zed_int_all/zybo_int.c", "/media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/zed_int_all/zybo_io.h"], is_skip_copy_sources = False)

platform = client.get_component(name="arm_platform")
status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

status = platform.build()

status = platform.build()

comp.build()

status = platform.build()

comp.build()

vitis.dispose()

