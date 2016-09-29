idconv
================

`idconv` is an R package of wrapper functions to convert gene identifiers available from the `org.Hs.eg.db` or `org.Mm.eg.db` bioconductor packages.

Installation
============


    # install bioconductor dependencies
    source("http://bioconductor.org/biocLite.R")
    if(!require(AnnotationDbi)) biocLite("AnnotationDbi")
    if(!require(org.Hs.eg.db)) biocLite("org.Hs.eg.db")
    if(!require(org.Mm.eg.db)) biocLite("org.Mm.eg.db")

    # install idconv
    devtools::install_github("uhlitz/idconv")

Examples
========

Wrapper functions for specific identifiers:
-------------------------------------------

You can choose from the following predefined functions:

`SYMBOL_to_ENTREZID()`, `ENTREZID_to_SYMBOL`, `SYMBOL_to_ENSEMBL`, `ENSEMBL_to_SYMBOL`, `SYMBOL_to_REFSEQ`, `REFSEQ_to_SYMBOL`.

``` r
library(idconv)
SYMBOL_to_ENTREZID(c("EGR1", "FOS"))
```

    ## 'select()' returned 1:1 mapping between keys and columns

    ##   EGR1    FOS 
    ## "1958" "2353"

``` r
ENTREZID_to_SYMBOL(c("1958", "2353"))
```

    ## 'select()' returned 1:1 mapping between keys and columns

    ##   1958   2353 
    ## "EGR1"  "FOS"

``` r
SYMBOL_to_ENSEMBL(c("EGR1", "FOS"))
```

    ## 'select()' returned 1:1 mapping between keys and columns

    ##              EGR1               FOS 
    ## "ENSG00000120738" "ENSG00000170345"

``` r
ENSEMBL_to_SYMBOL(c("ENSG00000120738", "ENSG00000170345"))
```

    ## 'select()' returned 1:1 mapping between keys and columns

    ## ENSG00000120738 ENSG00000170345 
    ##          "EGR1"           "FOS"

Generic function
----------------

You can use the generic function to map other identifiers:

``` r
IDX_to_IDY(ids = "NM_005252", from = "REFSEQ", to = "ENSEMBL")
```

    ## 'select()' returned 1:1 mapping between keys and columns

    ##         NM_005252 
    ## "ENSG00000170345"

Or simply define your own custom conversion function:

``` r
REFSEQ_to_ENSEMBL <- function(ids) IDX_to_IDY(ids = ids, from = "REFSEQ", to = "ENSEMBL")
REFSEQ_to_ENSEMBL("NM_005252")
```

    ## 'select()' returned 1:1 mapping between keys and columns

    ##         NM_005252 
    ## "ENSG00000170345"

Non-unique mappings
===================

If more than one mapping is available, `AnnotationDbi` returns a warning (1:many mappings) and `idconv` wrapper functions return concatenated target IDs by default. If desired, wrapper functions in this package can be forced to return unique mappings. Forcing unique mappings is however not recommended.

``` r
SYMBOL_to_ENSEMBL("IER3", force_unique = F) # default
```

    ## 'select()' returned 1:many mapping between keys and columns

    ##                                                                                              IER3 
    ## "ENSG00000137331;ENSG00000237155;ENSG00000235030;ENSG00000227231;ENSG00000230128;ENSG00000206478"

``` r
SYMBOL_to_ENSEMBL("IER3", force_unique = NA)
```

    ## 'select()' returned 1:many mapping between keys and columns

    ## IER3 
    ##   NA

``` r
SYMBOL_to_ENSEMBL("IER3", force_unique = T)
```

    ## 'select()' returned 1:many mapping between keys and columns

    ##              IER3 
    ## "ENSG00000137331"

Subtype IDs
===========

When converting to RefSeq, a subtype for target IDs can be specified, eg. `NM` or `NP`:

``` r
SYMBOL_to_REFSEQ("IER3", to_sub = "NM")
```

    ## 'select()' returned 1:many mapping between keys and columns

    ##                  IER3 
    ## "NM_003897;NM_052815"

``` r
SYMBOL_to_REFSEQ("IER3", to_sub = "NP")
```

    ## 'select()' returned 1:many mapping between keys and columns

    ##        IER3 
    ## "NP_003888"
