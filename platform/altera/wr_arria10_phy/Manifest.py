def __helper():
  dirs = []
  if syn_device[:4] == "10as":    dirs.extend(["wr_arria10_phy"])
  if syn_device[:7] == "10ax027": dirs.extend(["wr_arria10_scu4_phy"])
  if syn_device[:7] == "10ax066": dirs.extend(["wr_arria10_phy"])
  if syn_device[:7] == "10ax115": dirs.extend(["wr_arria10_e3p1_phy"])
  return dirs

files = [ "wr_arria10_phy.vhd" ]

modules = {"local": __helper() }
