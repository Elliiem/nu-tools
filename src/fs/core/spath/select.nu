export module dest {

    def score-similarity [dest: string, dirname: string]: nothing -> int {
        let dest_chars = ($dest | split chars)
        let dest_len = ($dest_chars | length)
        let dirname_chars = ($dirname | split chars)
        let dirname_len = ($dirname_chars | length)

        mut dest_i = 0
        mut dirname_i = 0

        mut correct_c = 0
        mut error_c = 0
        mut too_many_c = 0
        mut too_little_c = 0

        mut dest_cur = null
        mut dirname_cur = null
        mut dest_last = null
        mut dirname_last = null

        while ($dest_i < $dest_len) {
            if ($dirname_i > $dest_i) {
                break
            }

            if ($dirname_i >= $dirname_len) {
                break
            }

            $dest_last = $dest_cur
            $dest_cur = ($dest_chars | get $dest_i)
            $dirname_last = $dirname_cur
            $dirname_cur = ($dirname_chars | get $dirname_i)

            if ($dest_cur == $dirname_cur) {
                $correct_c += 1
            } else {
                # too little check
                let dest_can_check_forwards = (($dest_i + 1) < $dest_len)

                if ($dest_can_check_forwards) {
                    let dest_next = ($dest_chars | get ($dest_i + 1))

                    if ($dest_next == $dirname_cur) {
                        $dest_i += 1
                        $too_little_c += 1

                        continue
                    }
                }

                # too many check
                let dirname_can_check_forwards = (($dirname_i + 1) < $dirname_len)

                if ($dirname_can_check_forwards) {
                    let dirname_next = ($dirname_chars | get ($dirname_i + 1))

                    if ((($dirname_next == $dest_cur) or ($dirname_next == $dirname_cur)) and ($dirname_last == $dirname_cur)) {
                        $dirname_i += 1
                        $too_many_c += 1

                        continue
                    }
                } else {
                    if ($dirname_last == $dirname_cur) {
                        $dirname_i += 1
                        $too_many_c += 1

                        continue
                    }
                }

                $error_c += 1
            }

            $dest_i += 1
            $dirname_i += 1
        }


        let normalized_dirname_len = ($dirname_len - $too_many_c + $too_little_c)

        let correct_reward = (100 / $normalized_dirname_len)
        let error_penalty = (100 / $dest_len)
        let mistake_penalty = ($error_penalty * 0.2)

        let mistake_c = ($too_many_c + $too_little_c)

        let score = ((($correct_c * $correct_reward) - ($error_c * $error_penalty)) - (($mistake_c ** 2) * $mistake_penalty))

        if (($normalized_dirname_len > $dest_len) or ($score < 30)) {
            return (-1)
        } else {
            return $score | into int
        }
    }


    def has-better-meta [cmp: record]: record -> bool {
        let dest = $in

        let better_score = ($dest.score > $cmp.score)
        let better_bmness = ((not $dest.val.is_bookmark) and $cmp.val.is_bookmark)
        let better_reprness = ((not $dest.val.is_repr) and $cmp.val.is_repr)

        return ($better_score or $better_bmness or $better_reprness);
    }

    def has-better-meta-force-bm [cmp: record]: record -> bool {
        let dest = $in

        let better_score = ($dest.score > $cmp.score)
        let better_bmness = (not $cmp.val.is_bookmark)
        let better_reprness = ((not $dest.val.is_repr) and $cmp.val.is_repr)

        return ($better_score or $better_bmness or $better_reprness);
    }

    def has-better-name [cmp: record]: record -> bool {
        let dest = $in

        let dest_name = ($dest.val.name)
        let dest_len = ($dest_name | str length)
        let cmp_name = ($cmp.val.name)
        let cmp_len = ($cmp_name | str length)

        if ($dest_len > $cmp_len) {
            if ($dest_name | str starts-with $cmp_name) {
                return false
            }
        } else if ($dest_len < $cmp_len) {
            if ($cmp_name | str starts-with $dest_name) {
                return true
            }
        } else {
            return false
        }

        return false
    }


    def select-valid-destinations [dir: record]: list<record> -> list<record> {
        mut ret = []

        for dest in $in {
            let score = (score-similarity $dest.name $dir.name)

            if ($score >= 50) {
                $ret = $ret | append {
                    val: $dest,
                    score: $score,
                }
            }
        }

        return $ret
    }


    export def force-bm [dir: record, fs: record]: list<record> -> record {
        let dests = ($in | select-valid-destinations $dir)

        if ($dests | is-empty) {
            if ($dir.span != null) {
                error make {
                    msg: "No available destination",
                    label: {
                        text: "to this dir",
                        span: $dir.span
                    }
                }
            } else {
                error make {
                    msg: ("No available destination with name: " + $dir.name),
                }
            }
        }

        mut best = ($dests | first)

        for dest in ($dests | skip 1) {
            if (not $dest.val.is_bookmark) {
                continue
            }

            if ($dest | has-better-meta-force-bm $best) {
                $best = $dest
                continue
            }

            if ($dest.score == 100 and $best.score == 100) {
                if ($dest | has-better-name $best) {
                    $best = $dest
                    continue
                }

                if ($dir.span != null) {
                    error make {
                        msg: "Multiple destinations are available",
                        label: {
                            text: "to this dir",
                            span: $dir.span
                        }
                    }
                } else {
                    error make {
                        msg: ("Multiple destinations are available for dir with name: " + $dir.name),
                    }
                }
            }
        }

        if (not $best.val.is_bookmark) {
            if ($dir.span != null) {
                error make {
                    msg: "No available bookmark",
                    label: {
                        text: "to this dir",
                        span: $dir.span
                    }
                }
            } else {
                error make {
                    msg: ("No available bookmark with name: " + $dir.name),
                }
            }
        }

        return $best.val
    }


    export def main [dir: record, fs: record]: list<record> -> record {
        if ($dir.use_bookmark) {
            return ($in | force-bm $dir $fs)
        }

        let destinations = ($in | select-valid-destinations $dir)

        if ($destinations | is-empty) {
            if ($dir.span != null) {
                error make {
                    msg: "No available destination",
                    label: {
                        text: "to this dir",
                        span: $dir.span
                    }
                }
            } else {
                error make {
                    msg: ("No available destination with name: " + $dir.name),
                }
            }
        }

        mut best = ($destinations | first)

        for dest in ($destinations | skip 1) {
            if ($dest | has-better-meta $best) {
                $best = $dest
                continue
            }

            if ($dest.score == 100 and $best.score == 100) {
                if ($dest | has-better-name $best) {
                    $best = $dest
                    continue
                }

                if ($dir.span != null) {
                    error make {
                        msg: "Multiple destinations are available",
                        label: {
                            text: "to this dir",
                            span: $dir.span
                        }
                    }
                } else {
                    error make {
                        msg: ("Multiple destinations are available for dir with name: " + $dir.name),
                    }
                }
            }
        }

        return $best.val
    }

}

export module repl {

}
