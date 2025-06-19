#' @title Calculate Persistent Homology via a Vietoris-Rips Filtration
#'
#' @description This "externally exported" R function gives the user access to
#'   the "internally exported" C++ function `ripser_cpp_dist()`.
#'
#' @param dataset "dist" object on which to compute persistent homology
#' @param max_dim maximum dimension
#' @param threshold maximum diameter
#' @returns an empty list
#' @examples
#' 
#' # validate computation on toy data set
#' dist_vec <- c(4, 3, 5, 5, 3, 4)
#' result <- ripserq:::ripser_cpp_dist(
#'   dist_vec,
#'   dim = 1,
#'   thresh = 6.0,
#'   ratio = 1.0,
#'   p = 2
#' )
#' result
#' 
#' # validate use of default threshold
#' ripserq:::ripser_cpp_dist(
#'   dist_vec,
#'   dim = 1,
#'   thresh = Inf,
#'   ratio = 1.0,
#'   p = 2
#' )
#' 
#' # validate compatibility with 'dist' class
#' ripserq:::ripser_cpp_dist(
#'   eurodist,
#'   dim = 1, thresh = 5000, ratio = 1.0, p = 2
#' )
#' 
#' # exposed R function with no explicit parameter settings
#' ripser_dist(dist_vec)
#' 
#' @export
ripser_dist <- function(
    dataset,
    max_dim = 1L,
    threshold = Inf
) {
  
  # pre-process parameters
  if (threshold == Inf) threshold <- max(dataset)
  
  # run `compute_barcodes()` and save result
  ans <- ripser_cpp_dist(
    dataset,
    dim = max_dim, thresh = threshold, ratio = 1., p = 2L
  )
  
  # return result
  ans
}
