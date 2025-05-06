use cell-path.nu *

export module cell-path {
    export def concat [x: any, y: any]: nothing -> cell-path {
        _concat $x $y
    }

    export def append [y: any]: [
        cell-path -> cell-path,
        list<any> -> cell-path,
        table<value: string, optional: bool> -> cell-path
    ] {
        _concat $in $y
    }

    export def empty []: nothing -> cell-path {
        $.
    }
}
