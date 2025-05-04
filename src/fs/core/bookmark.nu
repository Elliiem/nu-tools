use path.nu

use fs.nu
use dir.nu

def append-override [new: list<record>, from_abs: string]: list<record> -> list<record> {
    mut bookmarks = $in

    mut i = 0

    mut ret = []

    for bookmark in $bookmarks {
        if ((not ($new | any {$in.name == $bookmark.name})) and ($bookmark.path | path check is-child $from_abs)) {
            $ret = ($ret | append $bookmarks | get $i)
        }

        $i += 1
    }

    return ($ret | append $new)
}

export def available [fs: record]: string -> list {
    let path_abs = $in

    let dirpath_abs = ($path_abs | path split)

    mut ret = [] | append-override  $fs.bookmarks $path_abs

    mut cur = $fs

    for dir in ($dirpath_abs | skip 1) {
        $cur = ($cur | dir child $dir)

        match ($cur) {
            null => {
                return $ret
            }
            _ => {
                let local = $cur.bookmarks

                $ret = ($ret | append-override $local $path_abs)
            }
        }
    }

    return $ret
}

export def add [root_abs: string, name: string, path_abs: string]: record -> record {
    mut new_fs = ($in | fs ensure-dir $root_abs)

    let cellpath = ($new_fs | (fs get-cellpath $root_abs) | append "bookmarks" | into cell-path)

    let bookmark = {
        name: $name,
        path: $path_abs,
    }

    $new_fs = ($new_fs | update $cellpath ($new_fs | get $cellpath | append $bookmark))

    return $new_fs
}
