try:
    if board in ["spec", "svec", "vfchd", "common"]:
        modules = {"local" : [ board ] }
except NameError:
    pass
