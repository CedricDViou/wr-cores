try:
    if board in ["spec", "svec", "vfchd", "clbv2", "clbv3", "clbv4", "spidr4", "pxie-fmc", "common"]:
        modules = {"local" : [ board ] }
except NameError:
    pass
