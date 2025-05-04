export def is-str-literal []:  record -> bool {
    let span = $in

    let contents = (view span $span.start $span.end)

    return (($contents | str starts-with "\"") or ($contents | str ends-with "\""))
}
