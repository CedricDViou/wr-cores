fetchto = "../../ip_cores"

files = [
    "spec_phasebox.vhd",
    "spec_phasebox.ucf",
    "xwrc_board_phasebox.vhd",
]

modules = {
    "local" : [
        "../../",
        "../../board/spec",
    ],
    "git" : [
        "git://ohwr.org/hdl-core-lib/general-cores.git",
        "git://ohwr.org/hdl-core-lib/gn4124-core.git",
        "git://ohwr.org/hdl-core-lib/etherbone-core.git",
    ],
}
