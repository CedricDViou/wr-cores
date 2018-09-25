fetchto = "../../ip_cores"

files = [
    "cute_core_ref_top.vhd",
    "cute_ref_top.vhd",
    "cute_ref_top.ucf",
]

modules = {
    "local" : [
        "../../",
        "../../board/cute",
    ],
    "git" : [
        "git://ohwr.org/hdl-core-lib/general-cores.git",
        "git://ohwr.org/hdl-core-lib/etherbone-core.git",
    ],
}
