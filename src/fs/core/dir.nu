export def empty [path: string]: nothing -> record {
    return {
        name: ($path | path basename),
        path: $path,
        repr: null,
        is_reldir: false,
        bookmarks: [],
        children: [],
    }
}

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
        if (($child_dir.name | path basename) == $child) {
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

export def detach []: record -> record {
    let dir = $in

    return {
        name: $dir.name,
        path: $dir.path,
        repr: $dir.repr,
        is_relird: $dir.is_reldir,
        bookmarks: $dir.bookmarks,
    }
}
