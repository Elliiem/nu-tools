use std assert

use ../path.nu

export def minimzed [span?: record]: string -> list<record> {
    if ($span != null) {
        assert ($span | meta span is-str-literal) "Expected string literal span!"
    }

    let path = $in | path reldir remove
    assert ($path | str starts-with "/")

    mut ret = []

    mut dirname = ""

    mut parsing_dirname = true
    mut bookmark = false

    mut i = 0
    mut dirname_start = 0
    mut dirname_end = 0

    for char in ($path | split chars | skip 1) {
        match ($char) {
            '/' => {
                if ($parsing_dirname) {
                    $bookmark = true
                    $parsing_dirname = false
                } else {
                    $parsing_dirname = true

                    if ($span != null) {
                        $ret = $ret | append {
                            name: $dirname,
                            use_bookmark: $bookmark,
                            span: {
                                start: ($span.start + 2 + $dirname_start + ($bookmark | into int)),
                                end: ($span.start + 2 + $i + ($bookmark | into int))
                            },
                        }
                    } else {
                        $ret = $ret | append {
                            name: $dirname,
                            use_bookmark: $bookmark,
                            span: null,
                        }
                    }

                    $dirname = ""
                    $dirname_start = ($i + 1)

                    $bookmark = false
                }
            },
            _ => {
                $dirname = $dirname ++ $char

                $parsing_dirname = false
            },
        }

        $i += 1
    }

    if ($span != null) {
        $ret = $ret | append {
            name: $dirname,
            use_bookmark: $bookmark,
            span: {
                start: ($span.start + 2 + $dirname_start + ($bookmark | into int)),
                end: ($span.start + 2 + $i + ($bookmark | into int))
            },
        }
    } else {
        $ret = $ret | append {
            name: $dirname,
            use_bookmark: $bookmark,
            span: null,
        }
    }

    return $ret
}
