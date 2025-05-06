use fs.nu

export def with-name [name: string]: record -> list<record> {
    return ($in | fs where-dir {
        let dir = $in

        if ($dir.is_reldir) {
            if ($dir.repr != null) {
                if ($dir.repr == $name) {
                    return true
                }
            } else {
                if ($dir.name == $name) {
                    return true
                }
            }
        }

        return false
    } | each {
        {
            name: $in.name,
            path: $in.path,
            repr: $in.repr,
        }
    })
}
