#' Write H5AD
#'
#' Write a H5AD file from a \linkS4class{SingleCellExperiment} object.
#'
#' @param sce A \linkS4class{SingleCellExperiment} object.
#' @param file String containing a path to write the new `.h5ad` file.
#' @param X_name Name of the assay to use as the primary matrix (`X`) of the
#' AnnData object. If `NULL`, the first assay of `sce` will be used by default.
#' @param skip_assays Logical scalar indicating whether assay matrices should
#' be ignored when writing to `file`.
#'
#' @details
#' Setting `skip_assays=TRUE` can occasionally be useful if the matrices in
#' `sce` are stored in a format that is not amenable for efficient conversion
#' to a **numpy**-compatible format. In such cases, it can be better to create
#' an empty placeholder dataset in `file` and fill it in R afterwards.
#'
#' When first run, this function will instantiate a conda environment
#' containing all of the necessary dependencies. This will not be performed on
#' any subsequent run or if any other
#' **zellkonverter** function has been run prior to this one.
#'
#' The **anndata** package automatically converts some character vectors to
#' factors when saving `.h5ad` files. This can effect columns of `rowData(sce)`
#' and `colData(sce)` which may change type when the `.h5ad` file is read back
#' into R.
#'
#' @return A `NULL` is invisibly returned.
#'
#' @author Luke Zappia
#' @author Aaron Lun
#'
#' @seealso
#' [`readH5AD()`], to read a \linkS4class{SingleCellExperiment} file from a H5AD
#' file.
#'
#' [`SCE2AnnData()`], for developers to create an AnnData object from a
#' \linkS4class{SingleCellExperiment}.
#'
#' @examples
#' # Using the Zeisel brain dataset
#' if (requireNamespace("scRNAseq", quietly = TRUE)) {
#'     library(scRNAseq)
#'     sce <- ZeiselBrainData()
#'
#'     # Writing to a H5AD file
#'     temp <- tempfile(fileext = ".h5ad")
#'     writeH5AD(sce, temp)
#' }
#'
#' @export
#' @importFrom basilisk basiliskRun
writeH5AD <- function(sce, file, X_name = NULL, skip_assays = FALSE) {
    file <- path.expand(file)
    basiliskRun(
        env = anndata_env,
        fun = .H5ADwriter,
        sce = sce, file = file, X_name = X_name, skip_assays = skip_assays
    )
    invisible(NULL)
}

#' @importFrom reticulate import
.H5ADwriter <- function(sce, file, X_name, skip_assays) {
    anndata <- import("anndata")
    adata <- SCE2AnnData(sce, X_name = X_name, skip_assays = skip_assays)
    adata$write_h5ad(file)
}
