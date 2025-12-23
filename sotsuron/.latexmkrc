#!/usr/bin/env perl

# LaTeX processor
$latex = 'platex -synctex=1 -halt-on-error -interaction=nonstopmode';
$latex_silent = 'platex -synctex=1 -halt-on-error -interaction=batchmode';

# BibTeX processor
$bibtex = 'pbibtex';

# Index processor
$makeindex = 'mendex %O -o %D %S';

# DVI to PDF processor
$dvipdf = 'dvipdfmx %O -o %D %S';

# PDF mode (use latex -> dvipdf)
$pdf_mode = 3;

# Output directory
$out_dir = '.';

# Main file
@default_files = ('kato.tex');

# Exclude _preamble.tex from auto-compilation
$do_cd = 1;
add_cus_dep('tex', '', 0, 'ignore_preamble');
sub ignore_preamble {
    my ($base_name, $path) = fileparse($_[0]);
    if ($base_name eq '_preamble') {
        return 0;
    }
    return 1;
}

# Clean up auxiliary files
$clean_ext = 'fls fdb_latexmk aux log dvi synctex.gz nav out snm toc vrb bbl blg idx ind ilg';

# Maximum number of runs
$max_repeat = 5;

# File types to clean
@generated_exts = qw(aux bbl bcf blg fdb_latexmk fls log nav out run.xml snm synctex.gz toc vrb);
