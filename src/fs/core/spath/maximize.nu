use ../../../meta

use ../resolves.nu *
use ../path.nu
use ../reldirs.nu

use split.nu
use select.nu

def get-path-span []: record -> record {
    let span = $in

    if ($span | meta span is-str-literal) {
        return $span
    } else {
        return null
    }
}

export def main [fs: record]: string -> string {
    let span = ((metadata $in).span | get-path-span)

    let minimized = $in

    let dirpath = ($minimized | split minimzed $span)

    let reldirs =  $fs | reldirs with-name ($minimized | path reldir get)

    if (($reldirs | length) > 1) {
        error make {
            msg: "Multiple reldirs with the given name!",
        }
    }

    mut maximized = ($reldirs | first).path

    for dir in $dirpath {
        let dests = $maximized | destinations $fs
        let dest = $dests | select dest $dir $fs

        $maximized = $maximized | path join $dest.path
    }

    return $maximized
}

# export def main [fs: record]: string -> string {
#     let span = ((metadata $in).span)
#
#     let dirpath = $in | splitPath $span
#
#     mut maximized = ["/"]
#
#     for dir in $dirpath {
#         let cur_path = $maximized | path join
#
#         let canidates = ($fs | completions $cur_path | canidates $dir.name)
#         let canidate_c = ($canidates | length)
#
#         mut resolved_canidate = null
#
#         if ($canidate_c == 1) {
#             let canidate = ($canidates | first)
#
#             if ((not $canidate.is_bookmark) and $dir.use_bookmark) {
#                 error make {
#                     msg: "Explicitly requested bookmark doesnt exist",
#                 }
#             } else {
#                 $resolved_canidate = $canidates | first
#             }
#         } else if ($canidate_c > 1) {
#             for canidate in $canidates {
#                 if ($dir.use_bookmark) {
#                     if ($canidate.is_bookmark) {
#                         if ($resolved_canidate != null) {
#                             error make {
#                                 msg: "Unable to determine dir completion",
#                             }
#                         }
#
#                         $resolved_canidate = $canidate
#                     }
#                 } else {
#                     if (not $canidate.is_bookmark) {
#                         if ($resolved_canidate != null) {
#                             error make {
#                                 msg: "Unable to determine dir completion",
#                             }
#                         }
#
#                         $resolved_canidate = $canidate
#                     }
#                 }
#
#             }
#         } else {
#             error make {
#                 msg: "Unable to determine dir completion",
#             }
#         }
#
#         if ($resolved_canidate.is_bookmark) {
#             $maximized = $maximized | append ($resolved_canidate.path | path relative-to $cur_path)
#         } else {
#             $maximized = $maximized | append ($resolved_canidate.name)
#         }
#     }
#
#     return ($maximized | path join);
# }
