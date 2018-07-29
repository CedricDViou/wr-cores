fetchto = "../../ip_cores"

files = [
     "mini_core_ref_top.vhd"
]

modules = {
    "local" : [
        "../../",
        "../../board/mini",
    ],
    "git" : [
        "git://ohwr.org/hdl-core-lib/general-cores.git",
        "git://ohwr.org/hdl-core-lib/etherbone-core.git",
    ],
}
