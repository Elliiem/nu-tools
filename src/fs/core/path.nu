export def is-child [root: string]: string -> bool {
    let path = $in

    match (do --ignore-errors {$path | path relative-to $root}) {
        null => false
        _ => true
    }
}

export module reldir {
    export def remove []: string -> string {
        let path = $in

        mut i = 0

        for char in ($path | split chars) {
            match ($char) {
                '/' => {
                    break
                },
                _ => {
                    $i += 1
                },
            }
        }

        $path | str substring $i..($path | str length)
    }

    export def get []: string -> string {
        let path = $in

        mut i = 0

        for char in ($path | split chars) {
            match ($char) {
                '/' => {
                    break
                },
                _ => {
                    $i += 1
                },
            }
        }

        if ($i > 0) {
            $path | str substring 0..($i - 1)
        } else {
            "/"
        }
    }
}
