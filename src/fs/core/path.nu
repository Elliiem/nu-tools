export module check {

export def is-child [root: string]: string -> bool {
    let path = $in

    match (do --ignore-errors {$path | path relative-to $root}) {
        null => false
        _ => true
    }
}

}
