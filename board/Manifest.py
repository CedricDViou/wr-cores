try:
    if board in ["spec", "spec7", "svec", "vfchd", "clbv2", "clbv3", "clbv4", "common"]:
        modules = {"local" : [ board ] }
except NameError:
    pass
