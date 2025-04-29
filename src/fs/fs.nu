export def getChild [child: string]: record -> record {
    let parent = $in

    for child_dir in $parent.children {
        if (($child_dir.path | path basename) == $child) {
            return $child_dir
        }
    }

    return null
}

export def hasChild [child: string]: record -> bool {
    let parent = $in

    for child_dir in $parent.children {
        if (($child_dir.path | path basename) == $child) {
            return true
        }
    }

    return false
}

export def getChildIndex [child: string]: record -> int {
    let parent = $in

    mut i = 0

    for child_dir in $parent.children {
        if (($child_dir.path | path basename) == $child) {
            return $i
        }

        $i += 1
    }

    return null
}

export def ensurePath [path_abs: string]: record -> record {
    let fs = $in

    mut modified = $fs

    mut cur_cellpath_list = []
    mut cur_dirpath = []

    let dirpath = ($path_abs | path split | skip 1)

    for dirname in $dirpath {
        $cur_dirpath = $cur_dirpath | append $dirname

        let cur_dir = ($modified | get ($cur_cellpath_list | into cell-path))

        if (not ($cur_dir | hasChild $dirname)) {
            let children_cellpath = ($cur_cellpath_list | append "children" | into cell-path )

            $cur_cellpath_list = $cur_cellpath_list | append ["children", ($modified | get $children_cellpath | length)]

            $modified = $modified | update  $children_cellpath (($modified | get $children_cellpath) | append {
                path: ($cur_dirpath | path join),
                repr: null,
                is_reldir: false,
                bookmarks: [],
                children: [],
            })
        } else {
            $cur_cellpath_list = $cur_cellpath_list | append ["children", ($cur_dir | getChildIndex $dirname)]
        }
    }

    return $modified
}

export def getDir [path_abs: string]: record -> record {
    let dirpath = ($path_abs | path split | skip 1)

    mut cur = $in

    for dir in $dirpath {
        $cur = $cur | getChild $dir
    }

    return $cur
}

export def getDirListCellpath [path_abs: string]: record -> list<string> {
    let dirpath = ($path_abs | path split | skip 1)

    mut path = []
    mut cur = $in

    for dir in $dirpath {
        let child_i = $cur | getChildIndex $dir

        match ($child_i) {
            null => {
                return null
            },
            _ => {
                $path = ($path | append [children, $child_i])
            }
        }

        $cur = $cur | getChild $dir
    }


    return $path
}
