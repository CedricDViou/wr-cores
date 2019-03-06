def __helper():
  dirs = []
  if syn_device[:4] == "10as":    dirs.extend(["wr_arria10_phy"])
  if syn_device[:7] == "10ax027": dirs.extend(["wr_arria10_scu4_phy"])
  if syn_device[:7] == "10ax066": dirs.extend(["wr_arria10_phy"])
  if syn_device[:7] == "10ax115": dirs.extend(["wr_arria10_e3p1_phy"])
  if syn_device[:1] == "5":       dirs.extend(["wr_arria5_phy"])
  if syn_device[:4] == "ep2a":    dirs.extend(["wr_arria2_phy"])
  return dirs

files = [ "wr_altera_pkg.vhd", "xwrc_platform_altera.vhd" ]

modules = {"local": __helper() }
