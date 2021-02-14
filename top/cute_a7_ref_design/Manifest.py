fetchto = "../../ip_cores"

files = [
    "cute_a7_ref_design.vhd", 
    "cute_a7_ref_design.xdc", 
    "reset_gen.vhd"]

modules = {
    "local" : [
        "../../",
    ],
    "git" : [
        "https://ohwr.org/project/general-cores.git",
        "https://ohwr.org/project/etherbone-core.git",
    ],
}
