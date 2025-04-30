use path.nu *
use fs.nu *

def addBookmarks [new: list<record>, from_abs: string]: list<record> -> list<record> {
    mut bookmarks = $in

    mut i = 0

    mut ret = []

    for bookmark in $bookmarks {
        if ((not ($new | any {$in.name == $bookmark.name})) and ($bookmark.path | isChild $from_abs)) {
            $ret = ($ret | append $bookmarks | get $i)
        }

        $i += 1
    }

    return ($ret | append $new)
}

export def availableBookmarks [path: string]: record -> list {
    let dirpath = ($path | path split)

    let fs = $in

    mut ret = [] | addBookmarks  $fs.bookmarks $path

    mut cur = $fs

    for dir in ($dirpath | skip 1) {
        $cur = ($cur | getChild $dir)

        match ($cur) {
            null => {
                return $ret
            }
            _ => {
                let local = $cur.bookmarks

                $ret = ($ret | addBookmarks $local $path)
            }
        }

    }

    return $ret
}

export def createBookmark [name: string, path: string]: nothing -> record {
    return {
        name: $name,
        path: $path,
    }

}

export def addBookmark [root_abs: string, name: string, path_abs: string]: record -> record {
    mut modified = ($in | ensurePath $root_abs)

    let cellpath = ($modified | (getDirListCellpath $root_abs) | append "bookmarks" | into cell-path)

    $modified = ($modified | update $cellpath ($modified | get $cellpath | append (createBookmark $name $path_abs)))

    return $modified
}
