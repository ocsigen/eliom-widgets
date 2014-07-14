
opam pin add --no-action eliom-widgets .
opam pin add --no-action ocsigenserver 'https://github.com/ocsigen/ocsigenserver.git#master'
opam pin add --no-action js_of_ocaml 'https://github.com/ocsigen/js_of_ocaml.git#master'
opam pin add --no-action eliom 'https://github.com/ocsigen/eliom.git#master'
opam pin add --no-action ojwidgets 'https://github.com/ocsigen/ojwidgets.git#master'
opam pin add --no-action ojquery 'https://github.com/ocsigen/ojquery.git#master'
opam install --deps-only eliom-widgets
opam install --verbose eliom-widgets

do_build_doc () {
  make doc
  mkdir -p ${API_DIR}/server ${API_DIR}/client
  cp -Rf doc/client/wiki/*.wiki ${API_DIR}/client
  cp -Rf doc/server/wiki/*.wiki ${API_DIR}/server
  cp -Rf doc/manual-wiki/*.wiki ${MANUAL_SRC_DIR}/
}

do_remove () {
  opam remove --verbose eliom-widgets
}
