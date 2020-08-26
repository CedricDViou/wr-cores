fetchto = "../../ip_cores"

files = [
    "spidr4_wr_ref_top.vhd",
]

modules = {
    "local" : [
        "../../",
    ],
    "git" : [
        "git://ohwr.org/hdl-core-lib/general-cores.git",
    ],
}
