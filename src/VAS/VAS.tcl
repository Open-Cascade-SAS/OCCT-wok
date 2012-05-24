# Definitions for a product: VAS

# List of toolkits 
proc VAS:toolkits { } {
    return {}
}

# List of non-toolkits (resource units, executables etc., with associated info)
proc VAS:ressources { } {
    return [list [list both r VAS {} ]]
}

# Product name 
proc VAS:name { } {
    return VAS
}

# And short alias
proc VAS:alias { } {
    return VAS
}

# Dependency on other products
proc VAS:depends { } {
    return {}
}

proc VAS:CompileWith { } {
}

proc VAS:LinksoWith { } {
}

proc VAS:Export { } {
    return [list source runtime wokadm api]
}
