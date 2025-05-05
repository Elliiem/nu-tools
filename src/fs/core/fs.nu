use dir.nu

export def ensure-dir [path_abs: string]: record -> record {
    let fs = $in

    mut modified = $fs

    mut cur_cellpath_list = []
    mut cur_dirpath = []

    let dirpath = ($path_abs | path split | skip 1)

    for dirname in $dirpath {
        $cur_dirpath = $cur_dirpath | append $dirname

        let cur_dir = ($modified | get ($cur_cellpath_list | into cell-path))

        if (not ($cur_dir | dir has-child $dirname)) {
            let children_cellpath = ($cur_cellpath_list | append "children" | into cell-path )

            $cur_cellpath_list = $cur_cellpath_list | append ["children", ($modified | get $children_cellpath | length)]

            $modified = $modified | update  $children_cellpath (($modified | get $children_cellpath) | append {
                name: ($cur_dirpath | last)
                path: ($cur_dirpath | path join),
                repr: null,
                is_reldir: false,
                bookmarks: [],
                children: [],
            })
        } else {
            $cur_cellpath_list = $cur_cellpath_list | append ["children", ($cur_dir | dir child-index  $dirname)]
        }
    }

    return $modified
}

export def get-dir [path_abs: string]: record -> record {
    let dirpath = ($path_abs | path split | skip 1)

    mut cur = $in

    for dir in $dirpath {
        if ($cur == null) {
            return null
        }

        $cur = $cur | dir child $dir
    }

    return $cur
}

export def get-cellpath [path_abs: string]: record -> list<string> {
    let dirpath = ($path_abs | path split | skip 1)

    mut path = []
    mut cur = $in

    for dir in $dirpath {
        let child_i = $cur | dir child-index $dir

        match ($child_i) {
            null => {
                return null
            },
            _ => {
                $path = ($path | append [children, $child_i])
            }
        }

        $cur = $cur | dir child $dir
    }

    return $path
}
