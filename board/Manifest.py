try:
    if board in ["spec", "svec", "vfchd", "common", "svec7"]:
        modules = {"local" : [ board ] }
except NameError:
    pass
