use bookmark.nu *

def isStringLiteralSpan []:  record -> bool {
    let span = $in

    let contents = (view span $span.start $span.end)

    return (($contents | str starts-with "\"") or ($contents | str ends-with "\""))
}


def splitPath [span: record]: string -> list<record> {
    let generate_spans = $span | isStringLiteralSpan
    let span_path_start = $span.start + 2

    mut ret = []

    mut dirname = ""

    mut parsing_dirname = true
    mut bookmark = false

    mut i = 0
    mut dirname_start = 0
    mut dirname_end = 0

    for char in ($in | split chars | skip 1) {
        match ($char) {
            '/' => {
                if ($parsing_dirname) {
                    $bookmark = true
                    $parsing_dirname = false
                } else {
                    $parsing_dirname = true

                    if ($generate_spans) {
                        $ret = $ret | append {
                            name: $dirname,
                            use_bookmark: $bookmark,
                            span: {
                                start: ($span_path_start + $dirname_start + ($bookmark | into int)),
                                end: ($span_path_start + $i + ($bookmark | into int))
                            },
                        }
                    } else {
                        $ret = $ret | append {
                            name: $dirname,
                            use_bookmark: $bookmark,
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

    if ($generate_spans) {
        $ret = $ret | append {
            name: $dirname,
            use_bookmark: $bookmark,
            span: {
                start: ($span_path_start + $dirname_start + ($bookmark | into int)),
                end: ($span_path_start + $i + ($bookmark | into int))
            },
        }
    } else {
        $ret = $ret | append {
            name: $dirname,
            use_bookmark: $bookmark,
        }
    }

    return $ret
}

def availableCompletions [path_abs: string]: record -> list<record> {
    let fs = $in

    mut completions = []

    for bookmark in ($fs | availableBookmarks $path_abs) {
        $completions = $completions | append ($bookmark | merge {is_bookmark: true})
    }

    for child in (ls $path_abs) {
        $completions = $completions | append {
            name: ($child.name | path basename),
            path: null,
            is_bookmark: false,
        }
    }

    return $completions
}

def getCanidates [dirname: string]: list<record> -> list<record> {
    let completions = $in

    let dirname_len = ($dirname | str length)

    mut canidates = []

    for completion in $completions {
        let completion_len = ($completion.name | str length)

        if ($completion.name | str starts-with $dirname) {
            $canidates = $canidates | append $completion
        }
    }


    return $canidates
}

export def maximizePath [fs: record]: string -> string {
    let span = ((metadata $in).span)

    let dirpath = $in | splitPath $span

    mut maximized = ["/"]

    for dir in $dirpath {
        let cur_path = $maximized | path join

        let canidates = ($fs | availableCompletions $cur_path | getCanidates $dir.name)

        let canidate_c = ($canidates | length)

        mut resolved_canidate = null

        if ($canidate_c == 1) {
            let canidate = ($canidates | first)

            if ((not $canidate.is_bookmark) and $dir.use_bookmark) {
                error make {
                    msg: "Explicitly requested bookmark doesnt exist",
                }
            } else {
                $resolved_canidate = $canidates | first
            }
        } else if ($canidate_c > 1) {
            for canidate in $canidates {
                if ($dir.use_bookmark) {
                    if ($canidate.is_bookmark) {
                        if ($resolved_canidate != null) {
                            error make {
                                msg: "Unable to determine dir completion",
                            }
                        }

                        $resolved_canidate = $canidate
                    }
                } else {
                    if (not $canidate.is_bookmark) {
                        if ($resolved_canidate != null) {
                            error make {
                                msg: "Unable to determine dir completion",
                            }
                        }

                        $resolved_canidate = $canidate
                    }
                }

            }
        } else {
            error make {
                msg: "Unable to determine dir completion",
            }
        }

        if ($resolved_canidate.is_bookmark) {
            $maximized = $maximized | append ($resolved_canidate.path | path relative-to $cur_path)
        } else {
            $maximized = $maximized | append ($resolved_canidate.name)
        }
    }

    return ($maximized | path join);
}
