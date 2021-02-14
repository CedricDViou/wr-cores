try:
    if board in ["spec", "svec", "vfchd", "clbv2", "clbv3", "clbv4", "cute", "cute_a7", "common"]:
        modules = {"local" : [ board ] }
except NameError:
    pass
