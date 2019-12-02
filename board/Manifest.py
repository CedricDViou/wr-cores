try:
    if board in ["spec", "svec", "vfchd", "common", "svec7", "svec7a"]:
        modules = {"local" : [ board ] }
except NameError:
    pass
