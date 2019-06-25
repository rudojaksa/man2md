### NAME
man2md - man to (github) markdown convertor

### USAGE
      man topic | man2md [OPTIONS]
      or
      man topic > topic.txt
      man2md [OPTIONS] topic.txt > topic.md

### DESCRIPTION
Man2md just converts manpage or an interactive help, if it is man-like
formatted, into the markdown format suitable for the github README.md.

### OPTIONS
        -h  This help.
    -p SEC  Treat a section with name containig the SEC string (glob) as a
            preformatted.  Comma separated list is accepted too.

### VERSION
man2md-0.2 (c) R.Jaksa 2018 GPLv3

