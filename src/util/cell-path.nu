def _split []: [
    cell-path -> list<record<value: string, optional: bool>>,
    list<any> -> table<value: string, optional: bool>,
    table<value: string, optional: bool> -> table<value: string, optional: bool>,
] {
    let path = $in

    let type = $path | describe

    match ($type) {
        "cell-path" => {
            return ($path | split cell-path)
        },
        "list<any>" => {
            return ($path | each {
                {
                    value: $in,
                    optional: false,
                }
            })
        },
        "list<string>" => {
            return ($path | each {
                {
                    value: $in,
                    optional: false,
                }
            })
        },
        "list<int>" => {
            return ($path | each {
                {
                    value: $in,
                    optional: false,
                }
            })
        },
        "table<value: string, optional: bool>" => {
            return $path
        },
    }

    error make {
        msg: "Invalid type! Expected any of these [cell-path, list<any>, table<value: any, optional: bool>].",
        label: {
            text: "invalid type",
            span: (metadata $in).span,
        }
    }

    return null
}

alias _append = append

export def concat [x: any, y: any]: nothing -> cell-path {
    let x_split = $x | _split
    let y_split = $y | _split

    return ($x_split | _append $y_split | into cell-path)
}

export def append [y: any]: [
    cell-path -> cell-path,
    list<any> -> cell-path,
    table<value: string, optional: bool> -> cell-path
] {
    concat $in $y
}

export def empty []: nothing -> cell-path {
    $.
}
