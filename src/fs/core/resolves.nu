use fs.nu
use bookmark.nu
use path.nu

export def destinations [fs: record]: string -> list<record> {
    assert ($in | path is-absolute) "Given path is not absolute!"

    let path = $in

    mut replacements = []

    $replacements = $replacements | append ($path | bookmark available $fs | each {
        let bm = $in

        return {
            name: $bm.name,
            path: $bm.path,
            is_bookmark: true
            is_repr: false,
        }
    })

    let children = (ls -a $path)

    for child in $children {
        let dest = ($child.name | path basename)

        $replacements = $replacements | append {
            name: $dest,
            path: $dest,
            is_bookmark: false,
            is_repr: false,
        }

        let dir = ($fs | fs get-dir ($path | path join $child.name))

        if ($dir != null and $dir.repr != null) {
            $replacements = $replacements | append {
                name: $dir.repr,
                path: $dest,
                is_bookmark: false,
                is_repr: true,
            }
        }
    }

    return $replacements
}
