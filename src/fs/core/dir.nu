export def child [child: string]: record -> record {
    let parent = $in

    for child_dir in $parent.children {
        if (($child_dir.name | path basename) == $child) {
            return $child_dir
        }
    }

    return null
}

export def has-child [child: string]: record -> bool {
    let parent = $in

    for child_dir in $parent.children {
        if (($child_dir.name | fs path basename) == $child) {
            return true
        }
    }

    return false
}

export def child-index [child: string]: record -> int {
    let parent = $in

    mut i = 0

    for child_dir in $parent.children {
        if (($child_dir.name | path basename) == $child) {
            return $i
        }

        $i += 1
    }

    return null
}
