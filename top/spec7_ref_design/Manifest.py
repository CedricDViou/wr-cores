fetchto = "../../ip_cores"

files = [
    "gen_10mhz.vhd",
    "pll_62m5_500m.vhd",
    "spec7_wr_ref_top.vhd",
    "spec7_wr_ref_top.xdc",
    "spec7_wr_ref_top.bmm",
]

modules = {
    "local" : [
        "../../",
    ],
    "git" : [
        "git://ohwr.org/hdl-core-lib/general-cores.git",
        "git://ohwr.org/hdl-core-lib/etherbone-core.git",
    ],
}
