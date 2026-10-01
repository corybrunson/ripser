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
#' # validate clustering (only 0-degree homology)
#' ripserq:::ripser_cpp_dist(
#'   dist_vec,
#'   dim = 0,
#'   thresh = Inf,
#'   ratio = 1.0,
#'   p = 2
#' )
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
#' # test edge case
#' ripserq:::ripser_cpp_dist(
#'   dist(matrix(c(0,0,0,1), ncol = 2)),
#'   dim = 1, thresh = 1, ratio = 1, p = 2
#' )
#' \dontrun{
#' ripserq:::ripser_cpp_dist(
#'   dist(0),
#'   dim = 1, thresh = 1, ratio = 1, p = 2
#' )
#' }
#' 
#' # exposed R function with no explicit parameter settings
#' ripser_dist(dist_vec)
#' 
#' # validate compatibility with 'dist' class and different outputs
#' ripser_dist(
#'   UScitiesD,
#'   max_dim = 1, thresh = 1000
#' )
#' ripser_dist(
#'   UScitiesD,
#'   max_dim = 1, thresh = 930
#' )
#' ripser_dist(
#'   UScitiesD,
#'   max_dim = 1, thresh = 800
#' )
#' 
#' # FIXME: inconsistent results using an alternative data set
#' ripser_dist(
#'   eurodist,
#'   max_dim = 1, thresh = Inf
#' )
#' ripser_dist(
#'   eurodist,
#'   max_dim = 1, thresh = 600
#' )
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
