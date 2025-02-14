(lang dune 3.17)
(using menhir 3.0)

(name hx)

(generate_opam_files true)
(implicit_transitive_deps false)

(source
 (github hx-lang/hx))

(authors "Daniel Hillerström <daniel.hillerstrom@ed.ac.uk>")

(maintainers "Daniel Hillerström <daniel.hillerstrom@ed.ac.uk>")

(license LICENSE)

(documentation https://github.com/hx-lang/hx)

(package
 (name hx)
 (synopsis "An effect handler oriented programming")
 (description "A research programming language for exploring effect handler oriented programming")
 (depends
   (ocaml (>= 5.3.0))
   (menhir (>= 20240715))
 )
 (tags
  ("effect handlers" "programming language")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
